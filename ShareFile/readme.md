I had the hardest time with trying to asses ShareFile disk usage. The Storage Zone reported 950gb of 1TB used, while the Storage Summary Report that I ran only reported about 750gb used. Where is the storage being used? My coworker and I couldn't figure it out.

After spending an hour on the phone with Citrix support, they basically told us that they don't have a way to asses what is in the trash or view file usage in a tree format - seemingly basic administration tools just aren't available. In a last attempt, they told us to look at the API.

Fine, I looked at the API, and it took a while to get my head around. Hopefully this will help you to get over some initial hurdles.



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