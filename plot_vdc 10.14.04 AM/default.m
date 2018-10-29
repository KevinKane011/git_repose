function default(varname, value)
    if evalin('caller',['~exist(''' varname ''',''var'') || isempty(' varname ')'])
        assignin('caller',varname,value);
    end
end