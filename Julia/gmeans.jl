function gmeans(data, ad_threshold, iterations = 0)
##Performs the k-means method with increasing k's until for all the
# clusters the points within the cluster have a close to normal
# distribution (using the g-means algorithm)
#
# Input
# data          : the data, dimensioned : (N,P)
# ad_threshold  : the maximum ad-value that is allowed
# iterations    : [optional] number of times to repeat k-means, if not set (or 0)
#                 deterministic initialization of k-means is used
#
# Output
# groups    : the clusters output by k-means
# centers   : the center for every cluster
# ad        : the anderson-darling statistic for every cluster
#
# Copyright 2005-2006 Laboratori d'Aplicacions Bioacustiques
# For more information; errors; comments please contact codas@lab.upc.edu
#data = X
#ad_threshold = length(X)*0.0005

if Pkg.installed("Clustering") == nothing
    Pkg.add("Clustering")
    Pkg.update()
end    
if Pkg.installed("PyPlot") == nothing
    Pkg.add("PyPlot")
    Pkg.update()
end   
if Pkg.installed("MultivariateStats") == nothing
    Pkg.add("MultivariateStats")
    Pkg.update()
end   

using PyPlot
using Clustering
using MultivariateStats


dim         = size(data,2)
kmeansK     = 2
tdata       = data
ad          = 0
ready       = 0
ngroups     = 0
dgroups     = {}
groups      = {}
centers     = []

# we need at least a few points
if ( size(data,1) < 6 )
    groups[1]     = data
    centers[1,:]  = mean(data)
    ad[1]         = 0
    return;    
end
pcaData = fit(PCA, data, method=:cov,) #I use fit because i think it's a wrapper for pcacov(cov(...))
projected = pcaData.proj #TOD I'm not sur what kind of data should i take, look here line 5 - 10 https://github.com/JuliaStats/MultivariateStats.jl/blob/master/src/pca.jl

# AFTER THIS LINE CODE IS NOT SUPPOPRTED BY CISZQ

[pad, tad] = anderson_darling( projected, ad_threshold )
if ( pad == 1 | tad < 0 )
    groups{1}     = data
    centers(1,:)  = mean(data)
    ad[1]         = max(0, tad); # ignore possible error messages
    return
end


# boolean var; when true the data is checked on normal distribution prior
# to running it through k-means
initial_normality_check = 0

# boolean var; when true intermediate plots of the clustering of the data
# are drawn
plot_nice_figures = 0

# initialize two centers - only with deterministic initialization
ncenters        = mean(data);   # making this variable available because i dont want to mess up the code too much
if ( iterations == 0 )
    dpoint          = find_furthest_point( data,  ncenters )
    ncenters[2,:]   = dpoint
end

while (ready == 0)
    ready    = 1
    pad      = [];  # temp variable to store the result from ad-test
    tad      = [];  # temp variable to store the ad-statistic
    accepted = 0;   # used to keep track if the entire data set needs to be rerun with an increased k; or split off part of the data
    ndata    = [];  # temp variable used to store the data that was not normally distributed around its center
    rgroups  = 0;   # the number of groups that has to be reclassified

    maxad           = 0;    # variables to keep track of the maximum ad over the classified clusters
    maxad_index     = 0
    maxad_gindex    = 0
    maxad_pc        = []
    maxad_ev        = 0

    # initial check to see if the data is already normally distributed -
    # only if a group was removed in the previous round
    if ( initial_normality_check == 1 )
        # calculate the anderson-darling statistic
        # first get the principal component of the group
        [pc, latent, explained] = pcacov(cov(tdata))

        # project the points to the principal component
            projected = pc[:,1]"*tdata"

        # calculate the statistic along the component
        [pad, tad] = anderson_darling( projected, ad_threshold )

        if ( pad == 1 )
            accepted = accepted + 1
            ngroups  = ngroups + 1

            groups{ngroups}     = tdata
            centers(ngroups,:)  = mean(tdata)
            ad[ngroups]         = tad
            continue;  # this actually returns; ready is set to 1 above
        end
    end



    # perform k means
    if ( iterations == 0 )
        [kout, tcenters] = kmeans( tdata, kmeansK, "Start', ncenters, 'EmptyAction', 'singleton", "Display', 'off" )
    else
        [kout, tcenters] = kmeans( tdata, kmeansK, "Replicates', iterations, 'EmptyAction', 'singleton", "Display', 'off" )
    end
    ncenters = []
    
    # check if nice figures should be plotted
    if ( plot_nice_figures == 1 )
        figure;
        PyPlot.hold(true);
    end

    # store the clusters separately
    for i=1:kmeansK
        tgroups{i} = tdata[kout == i, :]
        
        # plot figures if necessary
        if ( plot_nice_figures == 1 )
            mcolor = i/kmeansK*4/10 + 0.4
            plot(tgroups{i}[:,1], tgroups{i}[:,2], ".', 'Color", [mcolor mcolor mcolor] )
            plot(tcenters[i,1], tcenters(i,2), "*black" )
        end
        
        # calculate the anderson-darling statistic
        if ( size(tgroups{i}, 1 ) < 6 )
                pad[i] = 1;
                tad[i] = 0;
        else
            
            # first get the principal component of the group
            tcov = cov(tgroups{i})
            if ( sum(sum(tcov != 0)) == 0 )
                # deal with zero covariance matrix; consider this a group
                pad[i] = 1
                tad[i] = -1
            else
                [pc, latent, explained] = pcacov(tcov)

                # project the points on the principal component
                projected = pc[:,1]"*tgroups{i}"

                # calculate the statistic along the component
                [pad[i], tad[i]] = anderson_darling( projected, ad_threshold )
            end
        end

        # check if this cluster is accepted and do some accounting
        # except if the ad-test returned 1; or if the data had 0 std
        # no point in trying to split up the data any further in that case
            if ( pad[i] == 1 | (pad[i] == 0 & tad[i] == -1) )
            accepted = accepted + 1
            ngroups  = ngroups + 1

            groups{ngroups}     = tgroups{i}
            centers(ngroups,:)  = tcenters(i,:)
            ad[ngroups]         = max(0, tad(i)); # ignore possible error messages
        else
            ready               = 0
            rgroups             = rgroups + 1
            dgroups{rgroups}    = tgroups{i}
            ndata               = [ndata; tgroups{i}]
            ncenters[rgroups,:] = tcenters[i,:]

            # when tad is -2 it means that the distribution was far from
            # normal (log(0) error in anderson_darling.m)
            if ( tad[i] > maxad | maxad == 0 | tad[i] == -2 )
                maxad       != abs(tad[i])
                maxad_index     = rgroups
                maxad_gindex    = i
                    maxad_pc    = pc[:,1]
                maxad_ev        = latent[1]
            end
        end
    end

    if ( ready == 0 )
        # increase the kmeansK; take out the accepted clusters from the data
        kmeansK = kmeansK + 1 - accepted
        tdata   = ndata

        # split up the least-normally-distributed center
        if ( iterations == 0 )
            dpoint = find_furthest_point( tgroups{maxad_gindex}, tcenters(maxad_gindex,:) )
            ncenters[kmeansK,:]     = dpoint
        end
    end
    
    
    
    
        
end
return [groups, centers, ad]
end