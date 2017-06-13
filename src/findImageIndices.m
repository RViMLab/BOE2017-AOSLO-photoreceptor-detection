function  [idxX, idxY, toProcess] = findImageIndices(centresFinal, averageCellSize, imToUse)


idxX = (-floor(averageCellSize/2):floor(averageCellSize/2)) + round(centresFinal(1));
idxY = (-floor(averageCellSize/2):floor(averageCellSize/2)) + round(centresFinal(2));
    
    toProcess = within(1, idxX, size(imToUse, 2)) & ...
      within(1, idxY, size(imToUse, 1));
    
    toProcess = min(toProcess) == 1;

end