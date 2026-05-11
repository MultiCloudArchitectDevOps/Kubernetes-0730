for j in {1..10}; do  
    for i in {1..1000}; do  
        curl -s -o /dev/null -w "%{http_code}\n" http://a580f993ee7324a4f806801230c18859-721487315.us-east-1.elb.amazonaws.com/ &  
    done  
    wait  # Wait for all background curl processes to finish before next iteration
done
