# Sharefile API setup and intro ¯\_(ツ)_/¯
# Written by someone who has no idea what they're doing

# Purpose - To get a list of users and the amount of files they have in the trash that have not been removed or are unfindable by the cleaning service

<#
	Key words: bascially things I was searching for

	Citrix
	Sharefile
	Recycle bin
	clean recycle
	purge backup data
	delete recovery data
	true disk usage
	true size
	getTrueSize.ashx
	storage zone report
	storage detail
	recycle bin retention
#>

#############################################
# Step 1 - Get your access token
#############################################
	# Log in to your sharefile account then go to https://api.sharefile.com/apikeys
	# Create a new API Key or use the clinet ID and Client Secret of an existing key
	# If you create a new key, the Redirect URL is probably something like https://ScaryStuff-INC.sharefile.com/oauth/oauthcomplete.aspx - idk does it sound like I know what I'm doing?
	
	# Fill out the below variables

$companyName = #{company/subdomain}
$clientID = #{clientID}
$clientSecret = #{secret}

# Your sharefile login
$username = #{user.name@ScaryStuff-INC.com}
$password = #{password}

$employeeListPath = "$HOME\ShareFileUsers.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Set to avoid some random security error, I forget the specifics, try it without, doesn't matter to me
$reply = Invoke-RestMethod "https://$($companyName).sharefile.com/oauth/token?grant_type=password&client_id=$($clientID)&client_secret=$($clientSecret)&username=$($username)&password=$($password)"

Write-Host $reply

	# Reply looks something like this, I guess make sure that Admin_users and Admin_accounts reads true, probably important
	# {
	# 	"access_token": "fdkjsfnkldsfankldfndkjsfdjksafljkdashfbkjlds",
	# 	"refresh_token": "fghdjaskfdhajfghjdakfghjdaskgfhjasdgfhjkasdf",
	# 	"token_type": "bearer",
	# 	"expires_in": 28800,
	# 	"appcp": "sharefile.com",
	# 	"apicp": "sf-api.com",
	# 	"subdomain": "ScaryStuff-INC",
	# 	"access_files_folders": true,
	# 	"modify_files_folders": true,
	# 	"admin_users": true,
	# 	"admin_accounts": true,
	# 	"change_my_settings": true,
	# 	"web_app_login": true
	# }

$accessToken = $reply.access_token

#############################################
# Step 2 - Get a list of users
#############################################

Invoke-RestMethod "https://$($companyName).sf-api.com/sf/v3/Accounts/Employees?withRightSignature=false" -Headers @{'Authorization'="Bearer $($accessToken)";} -Method 'GET' -OutFile $employeeListPath

<#
	Compile Linux and open that json document up in vim or use some GUI editor if you're a heathen like me and remove the following:
	
	From the start of the file remove the following, basically the start to the ' "value": ' leaving [{"FirstName":"hjfkdshkjfd" at the start
		{"odata.metadata":"https://ScaryStuff-INC.sf-api.com/sf/v3/$metadata#Contacts","odata.count":2009,"value":

	From the end of the file remove the following including the comma:
		,"url":"https://ScaryStuff-INC.sf-api.com/sf/v3/Contacts"}

	Do it right and the JSON document should open up in in Firefox or your favorite JSON document viewer and be a pretty list of users,
	most importantly, we can use it to implement functionality that Citrix apparently thought was too useful to implement - seeing who has files in their recycle bin


	List will look something like this:
	{
		"FirstName": "bob",
		"LastName": "Smith",
		"Company": "ScaryStuff-INC",
		"IsConfirmed": true,
		"IsDisabled": false,
		"LastAnyLogin": "2021-02-09T13:18:39.487Z",
		"CreatedDate": "2016-09-12T19:06:31.667Z",
		"Name": "Smith, Bob",
		"Email": "Bob.Smith@ScaryStuff-INC.name",
		"odata.metadata": "https://ScaryStuff-INC.sf-api.com/sf/v3/$metadata#Contacts/ShareFile.Api.Models.Contact@Element",
		"odata.type": "ShareFile.Api.Models.Contact",
		"Id": "dfhjdaskfdkjsagfkajshfjksd",
		"url": "https://ScaryStuff-INC.sf-api.com/sf/v3/Contacts(dfhjdaskfdkjsagfkajshfjksd)"
	},
#>

Read-Host "Press enter when you've updated the JSON Document"

#############################################
# Step 3 - Get a list of users with trash
#############################################
try {
	$employeeList = Get-Content -Raw -Path $employeeListPath | ConvertFrom-Json
} catch {
	Write-Host "You didn't update the JSON Document did you? Or maybe it's formatted wrong, try opening it in Firefox first"
}


$usersWithTrash = New-Object System.Collections.Generic.List[System.Object] # Heard somewhere a list is more efficient than an array if it's going to be changing sizes
$count = 1

$employeeList | ForEach-Object {
	Write-Host "Processing: " $_.Name " - $count/$($employeeList.Count)"

	$trashReply = Invoke-RestMethod "https://$($companyName).sf-api.com/sf/v3/Items/UserDeletedItems?userid=$($_.Id)" -Headers @{'Authorization'="Bearer $($accessToken)";} -Method 'GET'

	if ( $trashReply.'odata.count' -ne 0 ) {
		Write-Host $_.Email " - " $trashReply.'odata.count'

		$usersWithTrash.Add( $_.Email + " - " + $reply.'odata.count' )
	}

	$count++
}