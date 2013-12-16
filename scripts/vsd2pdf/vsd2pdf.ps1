# Search "visio 2007 object model" at MSDN to find
# properties and methods of a specific object.


$dir=get-location;
$vsdfile = $dir.tostring()+"\"+$args[0];
$pdffile = $dir.tostring()+"\"+$args[1];
Write-Host $vsdfile "->" $pdffile;

$AppVisio = New-Object -ComObject Visio.Application; 
$vsddoc = $AppVisio.Documents.Open($vsdfile); 
# Write-Host "Page Name is: " $vsddoc.Pages.Item(1).Name;
$vsddoc.Pages.Item(1).ResizeToFitContents(); 
if (-not $vsddoc.saved ) {$vsddoc.Save();}
$vsddoc.ExportAsFixedFormat(1, $pdffile, 1, 0); 
$AppVisio.Quit();
