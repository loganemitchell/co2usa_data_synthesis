% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('No Outstanding questions.\n')
fprintf('Sally Newman estimated that the inlet heights are between 5-10m, so we agreed to set them to 8m. (email from 2019-08-27).\n')

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
date_issued = datetime(2019,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'san_francisco_baaqmd';
city_long_name = 'San Francisco (BAAQMD)';
city_url = 'https://www.baaqmd.gov/about-air-quality/air-quality-measurement/ghg-measurement';

% http://www.baaqmd.gov/research-and-data/air-quality-measurement/ghg-measurement/ghg-data
i=1;
provider(i).name = 'Sally Newman';
provider(i).address1 = 'BAAQMD Planning and Climate Protection Division';
provider(i).address2 = '375 Beale Street Suite 600';
provider(i).address3 = 'San Francisco, CA 94105';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Bay Area Air Quality Management District (BAAQMD)';
provider(i).email = 'snewman@baaqmd.gov';
provider(i).orcid = 'https://orcid.org/0000-0003-0710-995X';
provider(i).parameter = 'Provider has contributed measurements for: ';
i=2;
provider(i).name = 'Abhinav Guha';
provider(i).address1 = 'BAAQMD Planning and Climate Protection Division';
provider(i).address2 = '375 Beale Street Suite 600';
provider(i).address3 = 'San Francisco, CA 94105';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Bay Area Air Quality Management District (BAAQMD)';
provider(i).email = 'aguha@baaqmd.gov';
provider(i).orcid = 'https://orcid.org/0000-0001-7748-1971';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'http://www.baaqmd.gov/~/media/files/planning-and-research/ghg-data/readme-files/2017/timeseries_readme_file_spring2017-txt.txt?la=en';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_created_str = date_created_str;

i = 1;
site.codes{1,i} = 'BBY';
site.(site.codes{i}).name = 'BodegaBay';
site.(site.codes{i}).long_name = 'Bodega Bay';
site.(site.codes{i}).code = 'BBY';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {8};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 38.318756;
site.(site.codes{i}).in_lon = -123.072528;
site.(site.codes{i}).in_elevation = 21;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'BIS';
site.(site.codes{i}).name = 'BethelIsland';
site.(site.codes{i}).long_name = 'Bethel Island';
site.(site.codes{i}).code = 'BIS';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {8};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 38.006311;
site.(site.codes{i}).in_lon = -121.641918;
site.(site.codes{i}).in_elevation = -2;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'LIV';
site.(site.codes{i}).name = 'Livermore';
site.(site.codes{i}).long_name = 'Livermore';
site.(site.codes{i}).code = 'LIV';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {8};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 37.687526;
site.(site.codes{i}).in_lon = -121.784217;
site.(site.codes{i}).in_elevation = 137;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'SMT';
site.(site.codes{i}).name = 'SanMartin';
site.(site.codes{i}).long_name = 'San Martin';
site.(site.codes{i}).code = 'SMT';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {8};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 37.079379;
site.(site.codes{i}).in_lon = -121.600031;
site.(site.codes{i}).in_elevation = 86;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

% I wasn't able to find any data online from Patterson Pass.
% i = i+1;
% site.codes{1,i} = 'ptp';
% site.(site.codes{i}).name = 'PattersonPass';
% site.(site.codes{i}).long_name = 'Patterson Pass';
% site.(site.codes{i}).code = 'PTP';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {0};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4','co'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
% site.(site.codes{i}).in_lat = 37.689615;
% site.(site.codes{i}).in_lon = -121.631916;
% site.(site.codes{i}).in_elevation = 526;
% site.(site.codes{i}).date_issued = datetime(2018,07,01);
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');


%% Loading the data

for i = 1:length(site.codes)
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            
            % v20180409 of the data had minute averages and needed to be hourly averaged. Newer versions of the data are already hourly averaged. 
%             if ~exist(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']),'file')
%                 fprintf('Computing %s hourly %s averaged data...\n',site.codes{i},sptxt)
%                 
%                 site.(site.codes{i}).files = dir(fullfile(readFolder,city,[upper(sptxt),'_*',site.(site.codes{i}).name,'*.csv']));
%                 site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [];
%                 site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [];
%                 for fn = 1:length(site.(site.codes{i}).files)
%                     formatSpec = '%s%f';
%                     
%                     % Read the data file
%                     fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
%                     read_dat = textscan(fid,formatSpec,'HeaderLines',0,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
%                     fclose(fid);
%                     
%                     site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt]); read_dat{1,2}(:,1)]; % species
%                     site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']); ...
%                         datetime(read_dat{1,1},'InputFormat','dd-MMM-yyyy HH:mm:ss')]; % time
%                     fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
%                 end
%                 
%                 % Sort the data in chronological order since it wasn't necessarily loaded that way.
%                 [site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']),sort_index] = sortrows(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']));
%                 site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(sort_index,1);
%                 
%                 % Removes the leading and trailing NaNs
%                 data_range_ind = find(~isnan(site.(site.codes{i}).(['min_',sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).(['min_',sptxt,'_',intxt])),1,'last');
%                 site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(data_range_ind);
%                 site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(data_range_ind);
%                 clear sort_index data_range_ind
%                 
%                 % Creating an hourly averaged data set from the minute data.
%                 qht = (dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(1),'start','hour'):1/24:dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(end),'start','hour'))'; % Date numbers of the floored hours.
%                 qhdata = nan(size(qht,1),1);
%                 qhdataStd = nan(size(qht,1),1);
%                 qhdataCount = nan(size(qht,1),1);
%                 qtFloorHour = dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']),'start','hour');
%                 
%                 tic
%                 for j = 1:size(qht,1)
%                     qhdataTemp = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(qtFloorHour==qht(j,1),:);
%                     if size(qhdataTemp,1)>=2 % Must be at least two data points in order to save an "hourly average"
%                         qhdata(j,:) = nanmean(qhdataTemp,1);
%                         qhdataStd(j,:) = nanstd(qhdataTemp,1);
%                         qhdataCount(j,:) = sum(~isnan(qhdataTemp));
%                     end
%                 end
%                 toc
%                 save(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']),'qht','qhdata','qhdataStd','qhdataCount')
%             else
%                 fprintf('Loading previously computed %s hourly %s averaged data.\n',site.codes{i},sptxt)
%                 load(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']))
%             end
%             
%             site.(site.codes{i}).([sptxt,'_',intxt]) = qhdata;
%             site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = qhdataStd;
%             site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = qhdataCount;
%             site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = qht;
%             
%             % No uncertainty data yet.
%             site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            version_folder = 'v20190815';

            formatSpec = '%s%s%s%f%f%f%f%f%f';
            
            % Read the data file
            site.(site.codes{i}).files = dir(fullfile(readFolder,city,version_folder,['*',site.(site.codes{i}).name,'*.csv']));
            fid = fopen(fullfile(site.(site.codes{i}).files.folder,site.(site.codes{i}).files.name));
            read_dat = textscan(fid,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
            fclose(fid);
            
            % All of BAAQMD sites have columns for CO2, CH4, CO
            if strcmp(sptxt,'co2'); col.species = 3; col.std = nan; col.unc = 4; end
            if strcmp(sptxt,'ch4'); col.species = 1; col.std = nan; col.unc = 2; end
            if strcmp(sptxt,'co'); col.species = 5; col.std = nan; col.unc = 6; end
            
            site.(site.codes{i}).([sptxt,'_',intxt]) = read_dat{1,2}(:,col.species); % species
            
            if strcmp(sptxt,'ch4'); site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])*1000; end % convert ppm to ppb
            
            %site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = read_dat{1,2}(:,col.std); % species std
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = nan(length(read_dat{1,2}(:,col.species)),1); % species std
            %site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = read_dat{1,2}(:,col.n); % species n
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = nan(length(read_dat{1,2}(:,col.species)),1); % species n
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = read_dat{1,2}(:,col.unc); % species uncertainty
            
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(read_dat{1,1}(:,3),'InputFormat','M/d/yy HH:mm');% time
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']).Minute = 0; % Sets the minute to be 0.
            clear col
            fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files.name)
            
            % Remove any data that was blank:
            site.(site.codes{i}).([sptxt,'_',intxt]) =  site.(site.codes{i}).([sptxt,'_',intxt])(~isnat(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])),:);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) =  site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(~isnat(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])),:);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) =  site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(~isnat(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])),:);
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) =  site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(~isnat(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])),:);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) =  site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(~isnat(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])),:);
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set. 
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Set fill values:
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_unc']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lat']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lon']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']))) = -9999.0;
            
            site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).code,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
    fprintf('---- %-6s complete ----\n\n',site.codes{i})
end

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

%% Creating the netCDF file

fprintf('Now creating the netCDF files.\n')
eval('co2usa_create_netCDF')


