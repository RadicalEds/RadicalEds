**Day** 004 / **Date** (2025-11-04)    
**What I Worked On**:     
Did HTB beginner Challenge 'Redeemer'    
    
Created a script to track the 100 Days Event progress.    
it uses mongodb and curl with the v9 message search endpoint to keep track of thread activity.    
    
Currently, processing (with bash) is slow, due to the facts that we are processing linearly and we dont share a single database connection like we would in nodejs and other languages    
    
atm we only print the totals. in the future we will have different switches/flags to output various things, such as a list of users/threads that are in danger of being disqualified from inactivity.    
    
**What I Completed**: The Things I worked on    
**Progress Vs Yesterday**: Another Day For 100 Days    
**Evidence**: See Attached Files    
**Next Steps**: Need to Polish its output options a bit more, and improve its overall speed.    
