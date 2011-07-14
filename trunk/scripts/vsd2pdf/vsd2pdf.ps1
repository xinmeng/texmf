$dir=get-location;
$vsdfile = $dir.tostring()+"\"+$args[0];
$pdffile = $dir.tostring()+"\"+$args[1];
Write-Host $vsdfile "->" $pdffile;

$AppVisio = New-Object -ComObject Visio.Application; 
$vsddoc = $AppVisio.Documents.Open($vsdfile); 
$vsddoc.ExportAsFixedFormat(1, $pdffile, 1, 0); 
if (-not $vsddoc.saved ) {$vsddoc.Save();}
$AppVisio.Quit();
