# https://stackoverflow.com/questions/72055453/how-to-extract-the-variable-values-from-terraform-variables-tf-file-using-powers
# https://stackoverflow.com/questions/66463029/how-to-parse-a-terraform-file-versions-tf-in-bash
# https://stackoverflow.com/questions/56628680/can-we-parse-a-terraform-variables-tf-file-in-java-if-so-how-to-implement-the

# remove comments (even those starting with spaces)
# grep -vE '^\s*(#|$)' ./02-variables.tf > 03-variables.tf

# remove all comments from a file
# sed '/^[[:blank:]]*#/d;s/#.*//' ./03-variables.tf > 04-variables.tf
# grep -v description ./04-variables.tf | grep -v type > 05-variables.tf

# https://unix.stackexchange.com/questions/516105/i-want-to-parse-a-terraform-vars-file-and-store-variables-from-the-tf-vars-file

#################################################################################################
# variable "client_names" {
#     description = "Create Azure resources with these client names"
#     #type        = list(string)
#     type        = list 
#     default     = ["client-example", 
#                   "client-example",
#                   "client-example",
#                   "client-example",
#                   "client-example",
#                   "Enterprise",
#                   "Enterpriseux",
#                   "rajgupta", 
#                   "client-example"]
#   }
  
  
  
$product_list = (Get-Content "05-variables.tf" -Raw) | Foreach-Object {
    $_ -replace '(?s)^.*client_names', '' `
    -replace '(?s)variable.+' `
    -replace '[\[\],"{}]+' `
    -replace ("default =","") | Where { $_ -ne "" } | ForEach { $_.Replace(" ","") } | Out-String | ForEach-Object { $_.Trim() }
    }

foreach ( $Each_Product in $product_list.Split("`n")) {
write-host "Each Product Name : "$Each_Product
}










