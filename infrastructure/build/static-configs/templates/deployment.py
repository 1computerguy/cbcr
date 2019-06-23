from kubernetes import client

############################################################################
# Expected variables for context:
#
# Pod configuration
#   name - name to be used for pod, container, and deployment
#   image - container image to use
#   replicas - how many replicas to deploy
#
# Volume information
#   volumeName - name of volume mount
#   mountPath - container map location
#   nfsPath - nfs share path
#   nfsServer - nfs server hostname or ip
#
# Settings for environment variables:
#   keys in the format of - keys='IP_ADDR LEN GATEWAY INT'
#   vals in the format of - vals='1.2.3.4 8 1.0.0.1 net1'
#
# Settings for Pod Network connections must be in dictionary format
#   netkey in format of - netkey=k8s.v1.cni.cncf.io/networks
#   netval in format of - netval="bgpbr bgpbr bgpbr na-svc eu-ext"
#
#
# Example command to create a web Deployment:
#   kuku render -s name=web-test,image=master:5000/nginx,replicas=1,volumeName=web_test,mountPath='/etc/nginx/html',nfsPath='/configs/web/google.com',nfsServer=storage,netkey=k8s.v1.cni.cncf.io/networks,netval="na-svc" .
#
# Example command to create a router Deployment:
#   kuku render -s name=rtr-test,image=master:5000/frr,replicas=1,volumeName=rtr-test,mountPath='/etc/frr',nfsPath='/configs/med-fi/rtr-cfgs/rtr-us',nfsServer=storage,netkey=k8s.v1.cni.cncf.io/networks,netval="bgpbr bgpbr bgpbr na-svc external" .
#

# Define template for deployment
def template(context):
    labels = {"app": context["name"]}

    # Create volume mounts
    pod_spec_volume_mounts = [
        client.V1VolumeMount(name=context["volumeName"],
                        mount_path=context["mountPath"])
    ]

    # Create volumes
    pod_spec_volumes = [
        client.V1Volume(
            name=context["volumeName"],
            nfs=client.V1NFSVolumeSource(path=context["nfsPath"],
                                     server=context["nfsServer"])
        )
    ]

    # Create Environment variable list
    env_list = []
    if "env" in context:
        envs = dict(zip(context["env"].split(), context["vals"].split()))

        for key, val in envs.items():
            env_var = client.V1EnvVar(name=key, value=val)
            env_list.append(env_var)

    # Define the template specification
    template_spec = client.V1PodSpec(
        containers=[client.V1Container(name=context["name"],
            image=context["image"],
            env=env_list,
            security_context=client.V1SecurityContext(privileged=True),
            volume_mounts=pod_spec_volume_mounts)
        ],
        volumes=pod_spec_volumes
    )

    # Create dictionary for network attachment definition
    # This is required in a dictionary format for the template.metadata.annotations field
    net_dict = {}
    net_dict[context["netkey"]] = ', '.join(context["netval"].split())

    # Return deployment specification and tie together all the above components
    return client.V1Deployment(
        api_version="extensions/v1beta1",
        kind="Deployment",
        metadata=client.V1ObjectMeta(name=context["name"]),
        spec=client.V1DeploymentSpec(
            replicas=int(context["replicas"]),
            selector=client.V1LabelSelector(match_labels=labels),
            template=client.V1PodTemplateSpec(
                metadata=client.V1ObjectMeta(labels=labels,
                    annotations=net_dict),
                spec=template_spec
            ),
        ),
    )
