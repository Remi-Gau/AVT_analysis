Pattern component modelling
***************************

Scripts and functions related to pattern component modelling.

----


3 X 3 models
============


% 3X3 models
% on the 3 sensory modalities (A, V and T) but separately for
% ipsi and contra
%
% It has 12 models that represent all the different ways that those 3
% conditions can be either:
%
% - scaled
% - scaled and independent
% - independent
%
% See also `Set3X3models()`
%

    %
    % Generates the 12 models that represent all the different ways that those 3
    % conditions can be either:
    %
    % - scaled
    %
    % - scaled and independent
    %
    % - independent
    %
    % Used to run on the 3 sensory modalities (A, V and T) but separately for
    % ipsi and contra
    %
    % You don't have 3*3 models because of
    %
    % - transitivity issues where if T is a scaled version of V and V is a
    %   scaled version of A, then how can T be independent from A?
    %
    % - similarly some models can have 2 possible interpretations: e.g the 2 following can be
    %   described by the same model
    %
    %   - V is scaled to A
    %   - T is scaled and independent from A
    %   - T is scaled to V
    %
    %   - V is scaled to A
    %   - T is scaled to A
    %   - T is scaled and independent from V
    %

    % 3X3 models
    % the 3 sensory modalities (A, V and T) but separately for
    % ipsi and contra
    %
    % It has 12 models that represent all the different ways that those 3
    % conditions can be either:
    %
    % - scaled
    % - scaled and independent
    % - independent
    %
    % See also `Set3X3models()`
    %


.. figure::  pcm/3X3/3X3_model_family_comparison.svg
   :align:   center


.. automodule:: src.pcm

.. autoscript:: Pcm3x3models

.. automodule:: src.subfun.pcm

.. autofunction:: SetPcm3X3models


6 X 6 models
============

Let's go through example of visual areas

-   V = preferred
-   A, T = non-preferred

Now there are 3 options:

1. only scaled versions (`S`)
2. completely independent (`I`)
3. scaled + independent (`S+I`)

`S(A, V)` means A and V are scaled version of each other.

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


First possibility:

We do it factorially.

But this means that when Ipsi and Contra are independent, there can be almost as many possibilities
for ipsi and contra. So the models that are impossible (because of the "transitivity" issue described above)
or the models that are "redundant".

To make things simpler we only have things that can be independent OR scaled. Not both.

We also remove the 3rd factor.

And we do not create any model where Tactile is independent and Auditory and Visual conditions are scaled.

So we end up with a subset of models for 6X6.

See the tree of models (tree.html)


Linear mixed models
===================

.. autofunction:: src.bold_profiles.RunLMM


Underlying functions
====================

.. automodule:: src.subfun.pcm

.. autofunction:: RunPcm