pageextension 50120 UsingAPI extends "Contact List"
{
    actions
    {
        // Adiciona a action logo após o grupo de processamento "Functions" original
        addafter(History)
        {
            action(TestarIntegracaoPost)
            {
                ApplicationArea = All;
                Caption = 'Testar POST API';
                ToolTip = 'Dispara o envio de dados de teste para a API JSONPlaceholder.';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GetContactIntegrator: Codeunit ImportUsersIntegrator;
                begin
                    // Instancia e roda a Codeunit que criamos no passo anterior
                    GetContactIntegrator.FetchAndProcessUsers(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }
}