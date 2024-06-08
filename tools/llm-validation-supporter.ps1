param (
	[String]
	$TokenFileName = "tokens.txt"
)


"Please consider the following spec.md file and the following json schemas and try to find deviations between the written specification and the json schema." | Out-File -FilePath $TokenFileName
"`n-----> file spec.md:`n" | Out-File -FilePath $TokenFileName -Append
Get-Content "$PSScriptRoot/../spec.md" | Out-File -Append -FilePath $TokenFileName

Get-ChildItem -Path "$PSScriptRoot/../json-schema/" -Filter *.json -File -Recurse | ForEach-Object {
	"`n-----> file $($_.Name):`n" | Out-File -FilePath $TokenFileName -Append
	Get-Content $_.FullName | Out-File -Append -FilePath $TokenFileName
}