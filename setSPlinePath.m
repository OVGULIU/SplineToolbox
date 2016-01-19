close all;
clc;


% confirm dialog
str1= sprintf('Do you want to add %s to matlab system path?', pwd);
bname = questdlg(str1, ...
    'Add JLSpline Tool Path', ...
    'Yes', 'Cancel', 'Cancel');

switch bname
    case 'Yes'
        % save path
        addpath(pwd);
        savepath();
        % complete message
        msgbox('The JLSpline Tool path has been added sucessfully','Path Added');
        
    case 'Cancel'
        % complete message
        msgbox('User aborted!','Path Not Added');
end




