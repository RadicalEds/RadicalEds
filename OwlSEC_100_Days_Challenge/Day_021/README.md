# 🗓️ 𝒟𝒶𝓎 *021*        
-# Captains Log... Star Date:  ***11-21***        
        
__**𝒯**𝑜𝒹𝒶𝓎 𝐼 𝒲𝑜𝓇𝓀𝑒𝒹 𝒪𝓃__        
-# My First HackTheBox Machine "Conversor"

__**𝒲**𝒽𝒶𝓉 𝐼 𝒞𝑜𝓂𝓅𝓁𝑒𝓉𝑒𝒹__        
        
✅ `Conversor`
> Initial Scans reveal ports 22, 80
> gobuster revealed several pages including the `/about` page, which then contained the source code for the webapp
> 
> we see that its running flask, and read up on its sub routines.
> the server has a cron job, once every minute it runs all the python scripts in a certain directory
> 
> after some research we learned about XML namespace extensions and EXSLT.
> 
> Using an XML payload we exploited the `/convert` function to write a python payload to the scripts directory, waited a minute for cron to do its thing and then we recieved our reverse shell.
> 
> Initial access attained as `www-data` user, huzzah!
> 
> exploring the filesystem we enumerated /etc/passwd, found the login database for the webapp, looked through all the other user uploaded files, and discovered some interesting files in /tmp (perhaps left by the author as a hint, but they had everything needed for the upcoming privesc CVE)
> 
> after looking through the users database and using rainbow tables to get the md5 passwords, we now had the password for user 1000, (fismathack).
> 
> we logged in. got the user flag, searched for files, and checked permissions with sudo -l (this user can run one program as root, needrestart)
> 
> We then exploited needrestart with `CVE-2024-48990` to gain a root shell, got the root flag, and... bobs yours uncle


__**𝐸**𝓋𝒾𝒹𝑒𝓃𝒸𝑒__        
-# *See Attached Files*        
        
__**𝒫**𝓇𝑜𝑔𝓇𝑒𝓈𝓈__        
-# *Another Day For 100 Days*        
        
__**𝒩**𝑒𝓍𝓉 𝒮𝓉𝑒𝓅𝓈__        
-# *Keep On Keepin On*        
        
-# ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀    
-# ▀▄||  #HTB #HTBMachine #WordPress #OwlSEC #100days  ||▄▀        
-# ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀    
