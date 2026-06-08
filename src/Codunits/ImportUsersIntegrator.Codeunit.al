codeunit 50120 "ImportUsersIntegrator"
{
    trigger OnRun()
    begin
        
    end;

    procedure FetchAndProcessUsers(var ContactAPI: Record Contact)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
        JsonAsToken: JsonToken;
        JsonAsArray: JsonArray;
        I: Integer;
        Text01: Label 'A Resposta em texto é: %1';
    begin
        // 1. Fazemos a chamada HTTP GET para a API
        if not Client.Get('https://jsonplaceholder.typicode.com/users', Response) then
            Error('Falha ao conectar com o serviço de integração.');

        // 2. Verificamos se o status do retorno é 200 OK
        if not Response.IsSuccessStatusCode() then
            Error('A API retornou um erro: %1 - %2', Response.HttpStatusCode(), Response.ReasonPhrase());

        // 3. Lemos o corpo da resposta como Texto puro
        Response.Content().ReadAs(ResponseText);

        //Message(Text01, ResponseText);

        // 4. Convertemos o Texto para a estrutura genérica de JsonToken
        if not JsonAsToken.ReadFrom(ResponseText) then
            Error('O retorno da API não é um formato JSON válido.');

        // Como sabemos que a JSONPlaceholder retorna uma lista [], 
        // convertemos o Token genérico em um JsonArray
        if JsonAsToken.IsArray() then begin
            JsonAsArray := JsonAsToken.AsArray();
            
            // Loop para varrer cada usuário retornado na lista
            for I := 0 to JsonAsArray.Count() - 1 do begin
                JsonAsArray.Get(I, JsonAsToken); // Extrai o item atual do array
                
                // Processa o usuário individualmente
                ProcessSingleUser(JsonAsToken.AsObject(), ContactAPI);
            end;
            
            Message('%1 usuários foram processados com sucesso!', JsonAsArray.Count());
        end;
    end;

    local procedure ProcessSingleUser(UserObj: JsonObject; var InsertContactAPI: Record Contact)
    var
        IdToken: JsonToken;
        NameToken: JsonToken;
        EmailToken: JsonToken;
        AddressToken: JsonToken;
        CityToken: JsonToken;
        PhoneNoToken: JsonToken;
        StreetToken: JsonToken;
        SuiteToken: JsonToken;
        ZipcodeToken: JsonToken;

        ContacExist: Record Contact;
        RMSetup: Record "Marketing Setup";
        
        // Variáveis que receberiam os dados limpos
        UserId: Code[20];
        UserName: Text[100];
        UserEmail: Text[80];
        UserCity: Text[50];
        UserPhoneNo: Text[30];
        UserAddress: Text[100];
        UserPostCode: Text[20];
    begin
        // Extraindo dados diretos (Tipos primitivos)
        //if UserObj.Get('id', IdToken) then
        //    UserId := IdToken.AsValue().AsInteger();
            
        if UserObj.Get('name', NameToken) then
            UserName := CopyStr(NameToken.AsValue().AsText(), 1, 100);
            
        if UserObj.Get('email', EmailToken) then
            UserEmail := CopyStr(EmailToken.AsValue().AsText(), 1, 80);

        if UserObj.Get('phone', PhoneNoToken) then
            UserPhoneNo := CopyStr(PhoneNoToken.AsValue().AsText(), 1, 30);

        // EXTRAÇÃO AVANÇADA: O campo 'address' é outro JsonObject aninhado
        if UserObj.Get('address', AddressToken) then begin
            // Se conseguimos ler o nó 'address', extraímos a propriedade 'city' de dentro dele
            if AddressToken.AsObject().Get('street', StreetToken) then begin
                UserAddress := CopyStr(StreetToken.AsValue().AsText(), 1, 50)
            end;

            if AddressToken.AsObject().Get( 'suite', SuiteToken) then begin
                UserAddress += ' ';
                UserAddress += CopyStr(SuiteToken.AsValue().AsText(), 1, 49);
            end;

            if AddressToken.AsObject().Get('zipcode', ZipcodeToken) then begin
                UserPostCode := CopyStr(ZipcodeToken.AsValue().AsText(), 1, 20);
            end;

            if AddressToken.AsObject().Get('city', CityToken) then
                UserCity := CopyStr(CityToken.AsValue().AsText(), 1, 50);
        end;

        // --- Aqui entraria a sua lógica de persistência no BC ---
        // Exemplo fictício:
        ContacExist.Reset();
        ContacExist.SetFilter(Name, '=%1', UserName);
        ContacExist.SetFilter("E-Mail", '=%1', UserEmail);
        ContacExist.SetRange("Company Name", InsertContactAPI."Company Name");
        ContacExist.SetRange("Company No.", InsertContactAPI."Company No.");
        if ContacExist.FindFirst() then begin
            InsertContactAPI.Address := UserAddress;
            InsertContactAPI."Post Code" := UserPostCode;
            InsertContactAPI.City := UserCity;
            InsertContactAPI."Phone No." := UserPhoneNo;
            InsertContactAPI.Modify();
        end else begin
            RMSetup.Get();
            UserId := ObterProximoNumeroDeSerie(RMSetup."Contact Nos.");
            InsertContactAPI.Init();
            InsertContactAPI.Validate("No.", UserId);
            InsertContactAPI.Name := UserName;
            InsertContactAPI."E-Mail" := UserEmail;
            InsertContactAPI.Address := UserAddress;
            InsertContactAPI."Post Code" := UserPostCode;
            InsertContactAPI.City := UserCity;
            InsertContactAPI."Phone No." := UserPhoneNo;
            InsertContactAPI.Insert(true);
        end;
       
        // Apenas para debug visual durante o teste:
        //Message('ID: %1 \Nome: %2 \Cidade: %3', UserId, UserName, UserCity);
    end;

    procedure ObterProximoNumeroDeSerie(CodigoSerie: Code[20]): Code[20]
    var
        NoSeriesMgt: Codeunit "No. Series";
        NovoNumero: Code[20];
    begin
        if CodigoSerie = '' then
            exit('');
    
        // O método GetNextNo faz o trabalho pesado:
        // 1. Passa o Código da Série (ex: 'CUST')
        // 2. O segundo parâmetro é a WorkDate (Data de Trabalho), essencial se a série tiver vigência por datas
        // 3. O terceiro parâmetro (ModifySeries) como TRUE garante que o contador da série seja atualizado no banco
        NovoNumero := NoSeriesMgt.GetNextNo(CodigoSerie, WorkDate(), false);
        
        exit(NovoNumero);
    end;

    procedure PopularTabelaDaAPI(var ExtUser: Record ExternalUser): Integer;
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
        JsonAsToken: JsonToken;
        JsonAsArray: JsonArray;
        UserToken: JsonToken;
        UserObj: JsonObject;
        SubObj: JsonObject;
        TokenAux: JsonToken;
        I: Integer;
        //ExtUser: Record "ExternalUser";
    begin
        if not Client.Get('https://jsonplaceholder.typicode.com/users', Response) then
            Error('Falha ao conectar na API.');

        if not Response.IsSuccessStatusCode() then
            Error('Erro na API: %1', Response.HttpStatusCode());

        Response.Content().ReadAs(ResponseText);
        JsonAsToken.ReadFrom(ResponseText);
        JsonAsArray := JsonAsToken.AsArray();

        // Limpa os dados antigos antes de importar para teste
        ExtUser.DeleteAll();

        for I := 0 to JsonAsArray.Count() - 1 do begin
            JsonAsArray.Get(I, UserToken);
            UserObj := UserToken.AsObject();

            ExtUser.Init();
            
            if UserObj.Get('id', TokenAux) then ExtUser."Id" := TokenAux.AsValue().AsInteger();
            if UserObj.Get('name', TokenAux) then ExtUser."Name" := CopyStr(TokenAux.AsValue().AsText(), 1, 100);
            if UserObj.Get('username', TokenAux) then ExtUser."Username" := CopyStr(TokenAux.AsValue().AsText(), 1, 50);
            if UserObj.Get('email', TokenAux) then ExtUser."Email" := CopyStr(TokenAux.AsValue().AsText(), 1, 80);
            if UserObj.Get('phone', TokenAux) then ExtUser."Phone" := CopyStr(TokenAux.AsValue().AsText(), 1, 30);
            if UserObj.Get('website', TokenAux) then ExtUser."Website" := CopyStr(TokenAux.AsValue().AsText(), 1, 80);

            // Tratando objeto aninhado: address
            if UserObj.Get('address', TokenAux) then begin
                SubObj := TokenAux.AsObject();
                if SubObj.Get('street', TokenAux) then ExtUser."Address_Street" := CopyStr(TokenAux.AsValue().AsText(), 1, 100);
                if SubObj.Get('suite', TokenAux) then ExtUser."Address_Suite" := CopyStr(TokenAux.AsValue().AsText(), 1, 30);
                if SubObj.Get('city', TokenAux) then ExtUser."Address_City" := CopyStr(TokenAux.AsValue().AsText(), 1, 50);
                if SubObj.Get('zipcode', TokenAux) then ExtUser."Address_Zipcode" := CopyStr(TokenAux.AsValue().AsText(), 1, 20);
            end;

            // Tratando objeto aninhado: company
            if UserObj.Get('company', TokenAux) then begin
                SubObj := TokenAux.AsObject();
                if SubObj.Get('name', TokenAux) then ExtUser."Company_Name" := CopyStr(TokenAux.AsValue().AsText(), 1, 100);
            end;

            ExtUser.Insert();
        end;
        exit(JsonAsArray.Count());
    end;
}