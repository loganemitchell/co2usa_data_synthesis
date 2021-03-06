% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% netCDF creation documentation

% Following the Climate Forecasting conventions for netCDF files documented here:
% http://cfconventions.org/
% http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html
% 
% Also following the Attribute Convention for Data Discovery version 1.3
% https://wiki.esipfed.org/Attribute_Convention_for_Data_Discovery_1-3
%
% Variables must have a standard_name, a long_name, or both.
% A standard_name is the name used to identify the physical quantity. A standard name contains no whitespace and is case sensitive.
% A long_name has an ad hoc, human readable format.
% A comment can be used to add further detail, but is not required.
% 
% Time and date formating follow this convention:
% https://www.edf.org/health/data-standards-date-and-timestamp-guidelines
% 
% Data will be archived at the ORNL DAAC:
% https://daac.ornl.gov/PI/
% 

%% Creation date

% date_created: The date on which this version of the data was created. Recommended. 
date_created_now = datetime(now,'ConvertFrom','datenum','TimeZone','America/Denver'); date_created_now.TimeZone = 'UTC';
date_created_str = datestr(date_created_now,'yyyy-mm-ddThh:MM:ssZ');

% date_issued: The date on which this data (including all modifications) was formally issued (i.e., made available to a wider audience). Suggested.
date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2019,07,09);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'boston';
city_long_name = 'Boston';
city_url = 'http://atmos.seas.harvard.edu/lab/index.html';

i = 1;
provider(i).name = 'Maryann Sargent';
provider(i).address1 = 'Harvard University School of Engineering and Applied Sciences';
provider(i).address2 = '20 Oxford St';
provider(i).address3 = 'Cambridge, MA 02138';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Harvard University';
provider(i).email = 'mracine@fas.harvard.edu';
provider(i).orcid = 'https://orcid.org/0000-0001-9602-3108';
provider(i).parameter = 'Provider has contributed measurements for: ';

i = 2;
provider(i).name = 'Steven C. Wofsy';
provider(i).address1 = 'Harvard University School of Engineering and Applied Sciences';
provider(i).address2 = '20 Oxford St';
provider(i).address3 = 'Cambridge, MA 02138';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Harvard University';
provider(i).email = 'wofsy@g.harvard.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-3133-2089';
provider(i).parameter = 'Provider has contributed measurements for: ';


%% Site meta data

clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"

i = 1;
site.codes{1,i} = 'background';

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';

site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'modeled','modeled'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 42.3601;
site.(site.codes{i}).in_lon = -71.0589;
site.(site.codes{i}).in_elevation = 10;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;

% CO2 background:
sp = 1; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).name]}];
site.species = [site.species; {sptxt}];
site.(site.codes{i}).files = dir(fullfile(readFolder,city,'background','bound_*.txt'));
site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
site.(site.codes{i}).([sptxt,'_',intxt]) = [];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
for fn = 1:length(site.(site.codes{i}).files)
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        formatSpec = '%f%f%f%f%f'; % Yr,Mn,Dy,Hr,sp
        header_lines = 0;
        readNextLine = true;
        while readNextLine==true
            tline = fgets(fid);
            header_lines = header_lines+1;
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,5)]; % species mixing ratio
        
        site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
            datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
end

% In a new version of the data, -1e34 is used to represent missing values. 
site.(site.codes{i}).([sptxt,'_',intxt])(site.(site.codes{i}).([sptxt,'_',intxt])==-1e34) = -9999.0; 

% Removes the leading and trailing NaNs
data_range_ind = find(site.(site.codes{i}).([sptxt,'_',intxt])~=-9999.0,1,'first'):find(site.(site.codes{i}).([sptxt,'_',intxt])~=-9999.0,1,'last');
site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
clear data_range_ind
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;

% CH4 background:
sp = 2; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).name]}];
site.species = [site.species; {sptxt}];
site.(site.codes{i}).files = dir(fullfile(readFolder,city,'background','ch4_bg.txt'));
site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
site.(site.codes{i}).([sptxt,'_',intxt]) = [];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
for fn = 1:length(site.(site.codes{i}).files)
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        formatSpec = '%f%f%f%f%f'; % Yr,Mn,Dy,Hr,sp
        header_lines = 0;
        readNextLine = true;
        while readNextLine==true
            tline = fgets(fid);
            header_lines = header_lines+1;
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',', ','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,5)]; % species mixing ratio
        
        site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
            datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
end
% In a new version of the data, -1e34 is used to represent missing values. 
site.(site.codes{i}).([sptxt,'_',intxt])(site.(site.codes{i}).([sptxt,'_',intxt])==-1e34) = -9999.0; 

% Removes the leading and trailing NaNs
data_range_ind = find(site.(site.codes{i}).([sptxt,'_',intxt])~=-9999.0,1,'first'):find(site.(site.codes{i}).([sptxt,'_',intxt])~=-9999.0,1,'last');
site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
clear data_range_ind
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;


site.date_issued = date_issued;
site.date_issued_str = date_issued_str;
site.date_created_str = date_created_str;

site.reference = ['McKain K, Down A, Racit S M, Budney J, Hutyra L R, Floerchinger C, Herndon S C, Nehrkorn T, Zahniser M S, Jackson R B, Phillips N, and Wofsy S. (2015) Methane emissions from natural gas infrastructure and use in the urban region of Boston, Massachusetts. Proc Natl Acad Sci U.S.A. 112(7):1941-6.; ',...
 'Sargent, Maryann, Yanina Barrera, Thomas Nehrkorn, Lucy R. Hutyra, Conor K. Gately, Taylor Jones, Kathryn McKain, et al. Anthropogenic and Biogenic CO2 Fluxes in the Boston Urban Region. Proceedings of the National Academy of Sciences 115, no. 29 (July 17, 2018): 7491�96. https://doi.org/10.1073/pnas.1803715115.'];

fprintf('---- %-6s complete ----\n\n',site.codes{i})

% Identify the netCDF files to create based on species.
site.unique_species = unique(site.species);
site.species_list = [];
for species_ind = 1:length(site.unique_species)
    site.species_list = [site.species_list, site.unique_species{species_ind},' '];
end
site.species_list = strip(site.species_list); % Removes the last space

for j = 1:length(site.species)
    if strcmp(site.species{j,1},'co2')
        site.species_standard_name{j,1} = 'carbon dioxide';
    elseif strcmp(site.species{j,1},'ch4')
        site.species_standard_name{j,1} = 'methane';
    elseif strcmp(site.species{j,1},'co')
        site.species_standard_name{j,1} = 'carbon monoxide';
    end
end

%% Temporary code to truncate all sites to Dec 31, 2019 for the 4/21 ORNL DAAC archive

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            mask = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<datetime(2020,1,1); % Mask for data before 2020-01-01
            fields = {'','_std','_n','_unc','_time','_lat','_lon','_elevation','_inlet_height'};
            for j = 1:length(fields)
                site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]) = site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(mask); % Apply the mask
            end
        end
    end
end

%% Creating the netCDF file

fprintf('Now creating the netCDF files.\n')
eval('co2usa_create_netCDF')


