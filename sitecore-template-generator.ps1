function RunDialog() {
    ValidateItem
    $result = Read-Variable @props
    if ($result -ne "ok") {
        Exit
    }

    $container = GetTypeContainer
    $content = ""
    $fileName = "Templates.cs"
    # if current item is template folder then it generates multi types
    if ($item.TemplateId -eq '{0437FEE2-44C9-46A6-ABE9-28858D9FEE8C}') {
        $content = GenerateMultipleTypes
    }
    elseif ($item.TemplateId -eq '{AB86861A-6030-46C5-B394-E8F99E8B87DB}') {
        $content = GenerateType($item)
        $fileName = "$(SanitizeName($item)).cs"
    }
    $container = $container.replace('{placeholder}', $content)
    $container | Out-Download -Name $fileName
}

function GetTypeContainer() {
    $content = @"
    using Sitecore.Data;
    namespace $namespace
    {
        {placeholder}
    }
"@
    return $content
}

function GenerateMultipleTypes() {
    # get only templates
    $allTemplates = Get-ChildItem -path $item.Path -Recurse | Where-Object { $_.TemplateId -eq "{AB86861A-6030-46C5-B394-E8F99E8B87DB}" }
    $content = @"
    public struct Templates{
        $(foreach($template in $allTemplates){
                GenerateType($template)
        })
    }
"@
    return $content
}

function GenerateType($template) {
    try {
        $typeName = SanitizeName($template)
        $content = @"
            public struct $($typeName)
            {
                $(GetFieldsAsProps($template))
            }`n
"@
    
        return $content
    }
    catch {
        Write-Error $Error[0]
        Exit
    }
}

function GetFieldsAsProps($template) {
    $properties = ""
    # exclude sections
    $fields = Get-ChildItem -ID $template.ID -Recurse | Where-Object { $_.TemplateId -ne "{E269FBB5-3750-427A-9149-7AA950B49301}" }
    foreach ($field in $fields) {
        $fieldName= $field.Name.Replace(" ","")
        if ($propsType -eq 1) {
            $properties += "public static readonly string $($fieldName) = ""$($field.ID)""; `n "
        }
        else {
            $properties += "public static readonly ID $($fieldName) = new ID(""$($field.ID)""); `n "
        }
    }
    return $properties
}

function SanitizeName($template) {
    $name = $template.Name
    $name= $name.Replace(".", "").Replace("/", "").Replace("-", "").Replace("&amp;", "").Replace(":", "").Replace("""", "").Replace("#", "").Replace(" ","")
    
    if ($removeUnderscore -eq 1) {
        $name = $name.replace('_', '')
    }
    return $name
}

function ValidateItem() {
    
    $children = Get-ChildItem $item.Path
    if ($null -eq $children -or $children.Name -eq "__Standard Values") {
        Show-Alert -Title "Sorry this type not supported!"
        Exit
    }
}


$options = [ordered]@{
    "Yes" = 1
    "No"  = 0
}


$item = Get-Item .

$props = @{
    Parameters  = @(
        @{Name = "namespace"; Title = "Please enter your namespace"; Mandatory = $true }
        @{Name = "removeUnderscore"; Title = "Do you want to remove Underscore from the name of the Type?"; editor = "radio"; Value = 1; Options = $options; Mandatory = $true }
        @{Name = "propsType"; Title = "Do you want to generate properties of type string?"; Tooltip = "If you choose no then the default value will be ""ID"""; editor = "radio"; Value = 0; Options = $options; Mandatory = $true }
    )
    Title       = "Options"
    Description = "Choose options"
    ShowHints   = $true
}

RunDialog



