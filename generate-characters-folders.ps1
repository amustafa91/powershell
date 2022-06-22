$alph=@()
65..90|foreach-object{$alph+=[char]$_}


$numbers=@()
48..57|foreach-object{$numbers+=[char]$_}

# root folder
$root = "master:/sitecore/media library/Sites/ADPorts/News And Media"
foreach ($item in $numbers) {
    # Skip if the folder already exists
    if (@(Get-Item -Path "master:" -Query $root"/"$item).count -gt 0) {
        Continue
    # Create new item
    } else {
        New-Item -Path $root"/"$item -ItemType "/sitecore/templates/Common/Folder"
    }
}

foreach ($item in $alph) {
    # Skip if the folder already exists
    if (@(Get-Item -Path "master:" -Query $root"/"$item).count -gt 0) {
        Continue
    # Create new item
    } else {
        New-Item -Path $root"/"$item -ItemType "/sitecore/templates/Common/Folder"
    }
}



$mediaItems= Get-ChildItem -Path $root

foreach($item in $mediaItems){
    if($item.TemplateId -ne "{A87A00B1-E6DB-45AB-8B54-636FEC3B5523}"){
        $fChar= $item.Name[0]
        $newItemPath=$root+"/"+$fChar+"/"+$item.Name
        if (Test-Path -Path $newItemPath){
            Continue
        }
            Move-Item -Path $item.FullPath -Destination $root"/"$fChar
    }
}

