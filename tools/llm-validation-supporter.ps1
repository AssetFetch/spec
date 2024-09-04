<#
	.SYNOPSIS
		A short powershell script for generating a prompt for an LLM to aid with finding errors in the specification.
#>


param (
	[String]
	$PromptFileName = "prompt.txt"
)


"
---> INSTRUCTIONS:

Listed below are a technical standard document called spec.md and a list of JSON schema files.
Try to find inconsistencies between the data structures outlined in spec.md and the JSON schema files.
Make a list of such contradictions and give the exact section in spec.md and the name of the schema which are in contradiction.

" | Out-File -FilePath $PromptFileName

"`n---> file spec.md:`n" | Out-File -FilePath $PromptFileName -Append
Get-Content "$PSScriptRoot/../spec.md" | Out-File -Append -FilePath $PromptFileName

Get-ChildItem -Path "$PSScriptRoot/../json-schema/" -Filter *.json -File -Recurse | ForEach-Object {
	"`n---> file $($_.Name):`n" | Out-File -FilePath $PromptFileName -Append
	Get-Content $_.FullName | Out-File -Append -FilePath $PromptFileName
}