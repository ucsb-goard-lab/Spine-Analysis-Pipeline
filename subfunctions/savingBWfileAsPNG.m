%saving binarized images in a consistent manner to the others
days = [{'1'},{'2'},{'3'},{'4'},{'5'},{'6'},{'7'},{'8'},{'9'},{'10'},{'11'}];

oldFOlder1 = cd('NSW011_1_am');
for i=1:11
    BW = load(strcat(['BW_',num2str(i)]));
    BW = BW.BW;
    BW = imbinarize(imgaussfilt(double(BW),3),0.55); %imgaussfilt,medfilt2,
    file_name = strcat({'NSW011_1_E5_D'},string(days(i)),{'_gaus_mean_projection.mat'});
    
    oldFolder = cd('C:\Users\Goard Lab\Dropbox\CodeInBeta_Marie\DendriticSpines\Data\binarizedBranches');
    imwrite(BW,(strcat(erase(file_name,'.mat'),'.png')));
    cd(oldFolder);
end
cd(oldFOlder1)
oldFOlder12 = cd('NSW011_1_pm');
days = [{'1P'},{'2P'},{'3P'},{'4P'},{'5P'},{'6P'},{'7P'},{'8P'},{'9P'},{'10P'},{'11P'}];

for i=1:11
    BW = load(strcat(['BW_',num2str(i)]));
    BW = BW.BW;
    BW = imbinarize(imgaussfilt(double(BW),3),0.55); %imgaussfilt,medfilt2,
    file_name = strcat({'NSW011_1_E5_D'},string(days(i)),{'_gaus_mean_projection.mat'});
    
    oldFolder = cd('C:\Users\Goard Lab\Dropbox\CodeInBeta_Marie\DendriticSpines\Data\binarizedBranches');
    imwrite(BW,(strcat(erase(file_name,'.mat'),'.png')));
    cd(oldFolder);
end

cd(oldFOlder12)