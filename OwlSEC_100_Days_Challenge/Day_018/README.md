# 🗓️ 𝒟𝒶𝓎 *018*    
-# Captains Log... Star Date:  ***11-18***    
    
__**𝒯**𝑜𝒹𝒶𝓎 𝐼 𝒲𝑜𝓇𝓀𝑒𝒹 𝒪𝓃__    
-# I was pretty busy today, i did not get as much time as I usually have
-# However I did complete atleast one HTB Challenge to Keep things Going.   
    
__**𝒲**𝒽𝒶𝓉 𝐼 𝒞𝑜𝓂𝓅𝓁𝑒𝓉𝑒𝒹__    
    
✅ **`Debugging Interface`**    
> We are provided with a zipfile containing a single file with the sal extension
> Unknown to me i ran file and saw that this file is a zip archive, I unzipped it to discover a json file as well as a binary file
> I looked through the json file and didnt find anything of interset, so i then looked at the binary file.
> The Binary File Contained the Header `<SALEAE>`, after some googling we come across Saleae.com, a company that makes hardware analysing tools.
> In the Downloads Section I find an appimage for: `Saleae Logic 2`, and so i downloaded it.
> we imported the .sal file to the application and at this point, i had no idea what to do, so i found a walkthrough for the challenge, as well as learned a bit about the SALEAE Logic 2 software.
> In the End We used a logic 2 tool called "Async Serializer", Calculated a BitRate, and Viewed the tool in the terminal view, at the bottom was the flag we were looking for.
    
__**𝐸**𝓋𝒾𝒹𝑒𝓃𝒸𝑒__    
-# *See Attached Files*    
    
__**𝒫**𝓇𝑜𝑔𝓇𝑒𝓈𝓈__    
-# *Another Day For 100 Days*    
    
__**𝒩**𝑒𝓍𝓉 𝒮𝓉𝑒𝓅𝓈__    
-# *Learn More About SALEAE Logic 2*    
    
-# ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀    
-# ▀▄|| #HTB #HackTheBox #OwlSEC #100days ||▄▀    
-# ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀
