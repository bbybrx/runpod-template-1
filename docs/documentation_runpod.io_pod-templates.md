> ## Documentation Index
> Fetch the complete documentation index at: https://docs.runpod.io/llms.txt
> Use this file to discover all available pages before exploring further.

# Overview

> Streamline your Pod deployments with templates, bundling prebuilt container images with hardware specs and network settings.

export const PodEnvironmentVariablesTooltip = () => {
  return <Tooltip headline="Environment variables" tip="Key-value pairs that you can set in your Pod template and access within your code, allowing you to configure your application without hardcoding credentials or settings." cta="Learn more about Pod environment variables" href="/pods/templates/environment-variables">environment variables</Tooltip>;
};

export const PodTooltip = () => {
  return <Tooltip headline="Pod" tip="A dedicated GPU or CPU instance for containerized AI/ML workloads." cta="Learn more about Pods" href="/pods/overview">Pod</Tooltip>;
};

<PodTooltip /> templates are pre-configured Docker image setups that let you quickly spin up Pods without manual environment configuration. They're essentially deployment configurations that include specific models, frameworks, or workflows bundled together.

Templates eliminate the need to manually set up environments, saving time and reducing configuration errors. For example, instead of installing PyTorch, configuring JupyterLab, and setting up all dependencies yourself, you can select a pre-configured template and have everything ready to go instantly.

<iframe className="w-full aspect-video rounded-xl" src="https://www.youtube.com/embed/PwsTMASN7ac?si=noDNxOzehmjjvjnL" title="Deploying Pods from templates" frameBorder="0" allow="fullscreen; accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowFullScreen />

## What Pod templates include

Pod templates contain all the necessary components to launch a fully configured Pod:

* **Container image:** The Docker image with all necessary software packages and dependencies. This is where the core functionality of the template is stored, i.e., the software package and any files associated with it.
* **Hardware specifications:** Container disk size, volume size, and mount paths that define the storage requirements for your Pod.
* **Network settings:** Exposed ports for services like web UIs or APIs. If the image has a server associated with it, you'll want to ensure that the HTTP and TCP ports are exposed as necessary.
* **<PodEnvironmentVariablesTooltip />:** Pre-configured settings specific to the template that customize the behavior of the containerized application.
* **Startup commands:** Instructions that run when the Pod launches, allowing you to customize the initialization process.

## Types of templates

Runpod offers three types of templates to meet different needs:

### Official templates

Official templates are curated by Runpod with proven demand and maintained quality. These templates undergo rigorous testing and are regularly updated to ensure compatibility and performance. Runpod provides full support for official templates.

### Community templates

Community templates are created by users and promoted based on community usage. These templates offer a wide variety of specialized configurations and cutting-edge tools contributed by the Runpod community.

<Warning>
  Runpod does not maintain or provide customer support for community templates. If you encounter issues, contact the template creator directly or seek help on the [community Discord](https://discord.gg/runpod).
</Warning>

### Custom templates

You can create custom templates for your own specialized workloads. These can be private (visible only to you or your team) or made public for the community to use.

## Explore templates

<Frame alt="Browse Pod templates">
  <img src="https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=6a8ad036775ad180751b70180b6a875d" data-og-width="1692" width="1692" data-og-height="1279" height="1279" data-path="images/browse-pod-templates.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=280&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=a03e28335649d56c46cc3142709d8dcc 280w, https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=560&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=ecd1a37c470932a55e1914c667c0702d 560w, https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=840&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=6b54e3a25832d8ce533d21e37c1e299e 840w, https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=1100&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=ddc4188707aa37b9dd9663e7b7279b65 1100w, https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=1650&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=47c24e9791434e3b30f1e2989126e4a9 1650w, https://mintcdn.com/runpod-b18f5ded/fsmX6RlOJn_w5gqO/images/browse-pod-templates.png?w=2500&fit=max&auto=format&n=fsmX6RlOJn_w5gqO&q=85&s=126b54d60987bfada65e659358d00498 2500w" />
</Frame>

You can discover and use existing templates through the Runpod console:

**Browse all templates:** Visit the **[Explore](https://www.console.runpod.io/explore)** section to find official templates maintained by Runpod and community templates created by other users.

**Manage your templates:** Access templates you've created or that are shared within your team in the **[My Templates](https://www.console.runpod.io/user/templates)** section.

## Why use Pod templates

Templates provide significant advantages over manual Pod configuration:

* **Time savings:** Popular templates include options for machine learning frameworks like PyTorch, image generation tools like Stable Diffusion, and development environments with Jupyter notebooks pre-installed. This eliminates hours of manual setup and dependency management.
* **Consistency:** Templates ensure that your development and production environments are identical, reducing "it works on my machine" issues.
* **Best practices:** Official and popular community templates incorporate industry best practices for security, performance, and configuration.
* **Reduced errors:** Pre-configured templates minimize the risk of configuration mistakes that can lead to Pod startup failures or performance issues.
