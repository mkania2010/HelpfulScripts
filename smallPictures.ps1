# Finds all pictures that are less than the set $size and moves them to a folder
# useful if you want to collect smaller pictures from a large collection
# in theory should work on Unix, but haven't tried

param(
	[int]$size=3840,
	$path='C:\Users\'
)

add-type -AssemblyName System.Drawing
$smallPictures = @()

Set-Location $path
$pictures = Get-ChildItem

$pictures | ForEach-Object {
	if (((New-Object System.Drawing.Bitmap $_.FullName).Width) -lt $size) {
		Write-Host $_.Name "is smaller than" $size
		$smallPictures += $_
	}
}

Write-Host "Moving small pictures"
$smallPictures | ForEach-Object {
	Move-Item $_.FullName "./small/$($_.name)"
}