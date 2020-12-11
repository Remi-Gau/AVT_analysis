# 6 X 6 PCM models

Let's go through example of visual areas

-   V = preferred
-   A, T = non-preferred

Now there are 3 options:

1. only scaled versions (`S`)
2. completely independent (`I`)
3. scaled + independent (`S+I`)

`S(A, V)` means A and V are scaled version of each other.

Now we do it factorially:

-   Factor 1: Do stimuli from ipsi vs. contra elicit common, independent or
    partly shared representations?

    -   `S(Ipsi, Contra)`
    -   `S+I(Ipsi, Contra)`
    -   `I(Ipsi, Contra)`

-   Factor 2: Do stimuli from different sensory modalities elicit common,
    independent or partly shared representations?

    -   `S(A, V T)`
    -   `S+I(A, V, T)`
    -   `S+I(V vs. (A,T)) & S(A, T)`
    -   `I(V vs. (A,T)) & S(A, T)`
    -   `I(V vs. (A,T)) & S+I(A, T)`
    -   `I(A, V, T)`

-   Factor 3: Do we have additional ipsi vs. contra expression?
    -   yes
    -   no

## Model specification

model 1: null model

## Factor 1 & 2:

| factor 1 \ factor 2 | `S(A,V,T)`     | `S+I(A,V,T)`   | <p>`S+I(V vs. (A,T))` <br> `S(A,T)`</p> | <p>`I(V vs. (A,T))` <br> `S(A,T)`</p> | <p>`I(V vs. (A,T))` <br> `S+I(A,T)`</p> | `I(A,V,T)`      |
| ------------------- | -------------- | -------------- | --------------------------------------- | ------------------------------------- | --------------------------------------- | --------------- |
| `S(Ipsi, Contra)`   | model 2: 1,1,1 | model 3: 1,2,1 | model 4: 1,3,1                          |                                       |                                         |                 |
| `S+I(Ipsi, Contra)` |                |                | model 10: 2,3,1                         |                                       |                                         |                 |
| `I(Ipsi, Contra)`   |                |                |                                         |                                       |                                         | model 19: 3,6,1 |

## Factor 3: Non-specific effects of ipsi and contra

```matlab
% if true
M{mm}.Ac(:, end+1, end+1) = [1 0 1 0 1 0]';
M{mm}.Ac(:, end+1, end+1) = [0 1 0 1 0 1]';
```

<!-- So we test 36 models!
But importantly, plotting the model evidence factorially (e.g. using imagesc)
provides a more clear picture of what really influence those pattern

One may still criticize about this factorial exploration that even
when we allow Preferred and Non-preferred signals to induce independent pattern,
our exploration assumes that either both of them induce correlated or
uncorrelated ipsi and contra-lateral patterns …
but for the moment I would keep a bit more simple …
otherwise we run into factorial explosion,
because in principle A stim may induce lateralized activations,
but V do not etc. …
but I think once we have the best model we can still look at the parameters …
further, we have the cholesky model to check how well our model
fits the data and whether there is anything unmodelled. -->
