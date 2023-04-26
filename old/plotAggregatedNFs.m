% plot all nearfields:


numNFs = length(nearFields);
[sr, sc] = size(nearFields(1).EFields.ExTE);
intens = zeros(sr, sc);

for k = 1:numNFs
    NF = nearFields(k);
    intens = intens + propagateNearFieldStruct(NF, 6, 0, 0);
    
end

imagesc(repmat( intens(:, 1:2:end), 5, 5)), axis image, setfa
