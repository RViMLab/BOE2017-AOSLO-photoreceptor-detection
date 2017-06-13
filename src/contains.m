function res = contains(str1, str2)
%
% Returns true if str1 contains str2
%

  res = strfind(str1, str2);
  
  if ~isempty(res)
    res = true;
  else
    res = false;
  end

end