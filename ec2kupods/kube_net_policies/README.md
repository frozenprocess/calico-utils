# namespace for dns policies to work
kubectl label namespace kube-system name=kube-system
# remove label
kubectl label namespace kube-system name-