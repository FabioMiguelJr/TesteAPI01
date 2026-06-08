page 50140 "ExternalUserList"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ExternalUser";
    Caption = 'Usuários Externos (API)';
    CardPageId = "ExternalUserCard";
    Editable = false;


    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Id"; Rec."Id") { ApplicationArea = All; }
                field("Name"; Rec."Name") { ApplicationArea = All; }
                field("Username"; Rec."Username") { ApplicationArea = All; }
                field("Email"; Rec."Email") { ApplicationArea = All; }
                field("Address_City"; Rec."Address_City") { ApplicationArea = All; }
                field("Company_Name"; Rec."Company_Name") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SincronizarAcao)
            {
                ApplicationArea = All;
                Caption = 'Sincronizar API';
                ToolTip = 'Baixa os usuários da JSONPlaceholder e atualiza esta tabela.';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ImportUsersIntegrator: Codeunit ImportUsersIntegrator;
                    myInteger: Integer;
                begin
                    myInteger := ImportUsersIntegrator.PopularTabelaDaAPI(Rec);
                    CurrPage.Update(false);
                    Message('Tabela atualizada com sucesso com %1 registros!', myInteger);
                end;
            }
        }
    }

}