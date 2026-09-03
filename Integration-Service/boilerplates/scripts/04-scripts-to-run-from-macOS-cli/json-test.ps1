# $jsontest = @“
# [{
#     "resourceAppId": "00000000-0000-0000-0000-000000000000",
#     "resourceAccess": [
#         {
#             "id": "00000000-0000-0000-0000-000000000000",
#             "type": "Scope"
#         }
#    ]
# }]
# ”@ 

# write-host "content 1:"
# $jsontest
# ""
# ""
# ""

# $jsontest = $jsontest | ConvertFrom-Json

# write-host "content 2"
# $jsontest.resourceAppId
# write-host "content 3"
# $jsontest.resourceAccess
# write-host "content 4"
# $jsontest.resourceAccess.id


# ""
# ""
# ""
# ""
# ""
# ""
# ""
# ""
# ""

$graphId = 'graphid'
$userRead = 'userRead'

$resources = @"
[{ "resourceAppId": $graphId, "resourceAccess": [{"id": $userRead,"type": "Scope"}]}]
"@  

$resources

$resourceToJson = $resources | ConvertTo-Json
$resourceToJson


# $resources = $resources | ConvertFrom-Json
# $resources.resourceAppId