function [ color_map ] = brain_colour_maps(map2load)
%BRAIN_COLOUR_MAPS laods of the color maps from the brain color maps

color_map_lists = {
    'hot_increasing';...
    'continuous';...
    'semi_continuous';...
    'cool_decreasing';...
    };

if nargin==0
    map2load = 'hot_increasing';
end

map2load = lower(map2load);

if ~any(strcmp(map2load,color_map_lists))
    error('Not sure which color map to load.')
end


path = fileparts(which('brain_colour_maps.m'));
color_map = load(fullfile(path, 'brain_colour_maps', [map2load '.csv']));

end

