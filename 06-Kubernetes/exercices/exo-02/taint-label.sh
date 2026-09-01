kubectl taint nodes exo-02-worker country=france:NoExecute
kubectl taint nodes exo-02-worker2 country=usa:NoExecute
kubectl taint nodes exo-02-worker3 country=japan:NoExecute

kubectl label nodes exo-02-worker country=france
kubectl label nodes exo-02-worker2 country=usa
kubectl label nodes exo-02-worker3 country=japan