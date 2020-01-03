FROM amd64/ubuntu:19.10

RUN apt update
RUN apt install -y cmake g++
RUN apt install -y libglm-dev libxcb-dri3-0 libxcb-present0
RUN apt install -y libpciaccess0 libpng-dev libxcb-keysyms1-dev
RUN apt install -y libxcb-dri3-dev libx11-dev libmirclient-dev
RUN apt install -y libwayland-dev libxrandr-dev
RUN apt install -y libglfw3-dev
RUN apt install -y git
RUN apt install -y python
RUN apt install -y wget

RUN wget -O VulkanSDK.tar.gz https://sdk.lunarg.com/sdk/download/1.1.130.0/linux/vulkansdk-linux-x86_64-1.1.130.0.tar.gz?u=true && \
     mkdir VulkanSDK && \
     cd VulkanSDK && \
     tar xvf /VulkanSDK.tar.gz

 RUN	cd VulkanSDK/1.1.130.0
 ENV	VULKAN_SDK="/VulkanSDK/1.1.130.0/x86_64:${VULKAN_SDK}"
 ENV	PATH="${VULKAN_SDK}/bin:${PATH}"
 ENV	LD_LIBRARY_PATH="${VULKAN_SDK}/lib:${LD_LIBRARY_PATH}"
 ENV	VK_LAYER_PATH="${VULKAN_SDK}/etc/explicit_layer.d:${VK_LAYER_PATH}"