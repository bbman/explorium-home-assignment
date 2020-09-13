# home-assignment


Explorium files:
1. check-sg.sh
2. Jenkinsfile


```
chmod +x check-sg.sh
./check-sg.sh
```

Just run the script, this will: 
  - print all relavent SG (with 3 numbers in the Description text)
  - check SG is not related to Prod.
  - then it will go over loadbalancers
  - if one of LB is with 0 instances, it will detect the and remove the relvent SG on the list

Another option is to run the Jenkinsfile, just add it to a job and save.
it is already set to checkout this repo and run the shell script every Monday at 20:00. 
