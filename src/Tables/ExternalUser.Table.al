table 50140 "ExternalUser"
{
    DataClassification = CustomerContent;
    Caption = 'Usuário Externo';
    LookupPageId = "ExternalUserList";
    DrillDownPageId = "ExternalUserList";

    fields
    {
        field(1; "Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
        }
        field(2; "Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Nome';
        }
        field(3; "Username"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Usuário';
        }
        field(4; "Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'E-mail';
        }
        field(5; "Address_Street"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Rua';
        }
        field(6; "Address_Suite"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Complemento/Apto';
        }
        field(7; "Address_City"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Cidade';
        }
        field(8; "Address_Zipcode"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'CEP';
        }
        field(9; "Phone"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Telefone';
        }
        field(10; "Website"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Website';
        }
        field(11; "Company_Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Nome da Empresa';
        }
    }

    keys
    {
        key(PK; "Id")
        {
            Clustered = true;
        }
    }
}