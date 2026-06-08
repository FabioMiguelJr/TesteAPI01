pageextension 50111 "MyBusinessManagerExt" extends "Business Manager Role Center"
{
    actions
    {
        // Alterado para 'sections' para garantir a compatibilidade com o Business Manager
        addlast(sections)
        {
            group("MeuNovoMenu")
            {
                Caption = 'Meu Menu Customizado';
                ToolTip = 'Acesso rápido às minhas páginas customizadas.';
                
                action("MinhaPagina1")
                {
                    ApplicationArea = All;
                    Caption = 'Minhas Linhas de Integração';
                    ToolTip = 'Abre a página de gerenciamento de integrações.';
                    RunObject = page ExternalUserList; 
                }
                //action("MinhaPagina2")
                //{
                //    ApplicationArea = All;
                //    Caption = 'Configurações de API';
                //    ToolTip = 'Configurações gerais do sistema.';
                //    RunObject = page "Company Information"; 
                //}
            }//
        }
    }
}