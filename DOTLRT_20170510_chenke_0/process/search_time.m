function n= search_time(timetab,time)
for i=1:size(timetab,1)
    if isequal(timetab(i,:),time)
        break
    elseif ~isempty(findstr(timetab(i,:),time))
        break
    end
end
n=i;
end

