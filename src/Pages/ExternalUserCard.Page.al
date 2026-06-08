page 50141 "ExternalUserCard"
{
    PageType = Card;
    SourceTable = "ExternalUser";
    Caption = 'Ficha do Usuário Externo';

    layout
    {
        area(Content)
        {
            group(Geral)
            {
                Caption = 'Geral';
                
                field("Id"; Rec."Id") { ApplicationArea = All; ToolTip = 'ID do usuário obtido via API.'; }
                field("Name"; Rec."Name") { ApplicationArea = All; }
                field("Username"; Rec."Username") { ApplicationArea = All; }
                field("Email"; Rec."Email") { ApplicationArea = All; }
                field("Phone"; Rec."Phone") { ApplicationArea = All; }
                field("Website"; Rec."Website") { ApplicationArea = All; }
            }
            
            group(Endereco)
            {
                Caption = 'Endereço';
                
                field("Address_Street"; Rec."Address_Street") { ApplicationArea = All; }
                field("Address_Suite"; Rec."Address_Suite") { ApplicationArea = All; }
                field("Address_City"; Rec."Address_City") { ApplicationArea = All; }
                field("Address_Zipcode"; Rec."Address_Zipcode") { ApplicationArea = All; }
            }

            group(Empresa)
            {
                Caption = 'Empresa';
                
                field("Company_Name"; Rec."Company_Name") { ApplicationArea = All; }
            }
        }
    }
}