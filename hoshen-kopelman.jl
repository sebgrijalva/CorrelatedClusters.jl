function hoshen_kopelman(arr::Array{Int, 2})
    # Initialize cluster labels and next available label
    labels = zeros(Int, size(arr))
    next_label = 1

    # Iterate over elements in the array
    for i in 1:size(arr, 1)
        for j in 1:size(arr, 2)
            # If element is a 1, check for neighboring labels
            if arr[i, j] == 1
                neighbors = []
                if i > 1 && arr[i - 1, j] == 1 #check if there is a 1 above
                    push!(neighbors, labels[i - 1, j])
                end
                if j > 1 && arr[i, j - 1] == 1 #check if there is a 1 left
                    push!(neighbors, labels[i, j - 1])
                end
                if isempty(neighbors)
                    labels[i, j] = next_label
                    next_label += 1
                else
                    # If there are multiple neighbors, merge clusters                   
                    min_label = minimum(neighbors)
                    labels[i, j] = min_label
                    for neighbor in neighbors
                        if neighbor != min_label
                            labels[labels .== neighbor] .= min_label
                        end
                    end
                end
            end
        end
    end

    # Relabel clusters to be contiguous integers starting from 1
    # deep copy labels to relabeled
    relabeled = deepcopy(labels)
    next_relabel = 1
    for i in 1:maximum(labels)
        if any(labels .== i)
            # relabeled[labels .== i] .= labels[findall(labels .== i)[1]]
            relabeled[labels .== i] .= next_relabel
            next_relabel += 1
        end
    end

    return relabeled
end

# try a random array of 0s and 1s:
N = 7
arr = rand(0:1, 2^N, 2^N)
clusters = hoshen_kopelman(arr)
periodic_clusters = hoshen_kopelman_periodic(arr)

# import the plotting tools:
using PyPlot
using Colors
using FixedPointNumbers

# Generate a list of N random colors
# Add black as the first color in the list using N0f8:
N = 70
colors_list = [RGB(N0f8(0), N0f8(0), N0f8(0))]
for i in 1:N
  push!(colors_list, RGB(N0f8(rand()), N0f8(rand()), N0f8(rand())))
end

# Create the colormap using the ColorMap function
custom_colormap = ColorMap(colors_list)

# plot the array, the clusters and the periodic clusters to the right in the same figure:
fig, ax = subplots(1, 3, figsize=(6, 3))
ax[1].imshow(arr, cmap="binary")
ax[2].imshow(clusters, cmap=custom_colormap)
ax[3].imshow(periodic_clusters)#, cmap="colorsys")
tight_layout()

#no ticks:
for i in 1:3
    ax[i].set_xticks([])
    ax[i].set_yticks([])
end

# save the figure as a high resolution pdf:
savefig("figs/hoshen-kopelman.pdf", dpi=1200)
