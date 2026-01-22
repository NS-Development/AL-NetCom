// codeunit 50110 "NetCom One Drive"
// {
//     trigger OnRun()
//     begin

//     end;

//     procedure NetComShareWithOneDriveFromMedia(FileName: Text; FileExtension: Text; Folder: Text; MediaId: Guid)
//     var
//         DocumentSharingIntent: Enum "Document Sharing Intent";
//     begin
//         NetComInvokeDocumentSharingFlowFromMedia(FileName, FileExtension, Folder, MediaId, DocumentSharingintent::Share);
//     end;

//     local procedure NetComInvokeDocumentSharingFlowFromMedia(FileName: Text; FileExtension: Text; Folder: Text; MediaId: Guid; DocumentSharingIntent: Enum "Document Sharing Intent"): Boolean
//     var
//         TempDocumentSharing: Record "Document Sharing" temporary;
//         TenantMedia: Record "Tenant Media";
//         CryptographyManagement: Codeunit "Cryptography Management";
//         HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
//         InStream: InStream;
//         OutStream: OutStream;
//         Hash: Text;
//     begin
//         //Nedenstående funktion skal også laves som en kopi og her skal SubFolder også sendes med og gemmes i "TempDocumentSharing" som der skal laves en tableextension til med "Sub Folder" felt.
//         NetComSetFileNameAndExtension(TempDocumentSharing, FileName, FileExtension, Folder);

//         TenantMedia.Get(MediaId);
//         TenantMedia.CalcFields(Content);
//         TempDocumentSharing.Data := TenantMedia.Content;
//         TempDocumentSharing."Document Sharing Intent" := DocumentSharingIntent;
//         TempDocumentSharing.Insert();
//         TempDocumentSharing.Data.CreateInStream(InStream);
//         Hash := CryptographyManagement.GenerateHash(InStream, HashAlgorithmType::SHA1);
//         Codeunit.Run(Codeunit::"Document Sharing", TempDocumentSharing);

//         if (DocumentSharingIntent = Enum::"Document Sharing Intent"::Edit) and
//             (Hash <> CryptographyManagement.GenerateHash(InStream, HashAlgorithmType::SHA1)) then begin
//             TempDocumentSharing.Data.CreateInStream(InStream);
//             TenantMedia.Content.CreateOutStream(OutStream);

//             CopyStream(OutStream, InStream);
//             TenantMedia.Modify();
//             exit(true);
//         end;
//     end;

//     local procedure NetComSetFileNameAndExtension(var TempDocumentSharing: Record "Document Sharing" temporary; FileName: Text; FileExtension: Text; Folder: Text)
//     begin
//         TempDocumentSharing.Name := CopyStr(Folder + '_' + FileName, 1, MaxStrLen(TempDocumentSharing.Name) - StrLen(FileExtension)) + FileExtension;
//         TempDocumentSharing.Extension := CopyStr(FileExtension, 1, MaxStrLen(TempDocumentSharing.Extension));
//     end;
// }