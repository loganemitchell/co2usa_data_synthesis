clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% netCDF creation documentation

% Following the Climate Forecasting conventions for netCDF files documented here:
% http://cfconventions.org/
% http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html
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

date_created_now = datestr(now,'yyyy-mm-dd');
date_created_str = datestr(datenum(2018,07,01),'yyyy-mm-dd');
%date_created_SLC_CO2 = datestr(datenum(2017,07,11),'yyyy-mm-dd');

date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2019,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'indianapolis';
city_long_name = 'Indianapolis';
city_url = 'http://sites.psu.edu/influx/';


% http://www.datacommons.psu.edu/commonswizard/MetadataDisplay.aspx?Dataset=6150
% ftp://data1.commons.psu.edu/pub/commons/meteorology/influx/influx-tower-data/

provider(1).name = 'Natasha L. Miles';
provider(1).address1 = 'Penn State Department of Meteorology and Atmospheric Science';
provider(1).address2 = '412 Walker Building';
provider(1).address3 = 'University Park, PA 16802';
provider(1).country = 'United States';
provider(1).city = city_long_name;
provider(1).affiliation = 'Penn State Department of Meteorology and Atmospheric Science';
provider(1).email = 'nmiles@psu.edu';
provider(1).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/nlm136

provider(2).name = 'Scott J. Richardson';
provider(2).address1 = 'Penn State Department of Meteorology and Atmospheric Science';
provider(2).address2 = '414 Walker Building';
provider(2).address3 = 'University Park, PA 16802';
provider(2).country = 'United States';
provider(2).city = city_long_name;
provider(2).affiliation = 'Penn State Department of Meteorology and Atmospheric Science';
provider(2).email = 'srichardson@psu.edu';
provider(2).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/sjr17

%% Site meta data

site_full_names = {
    'Mooresville'; % 01
    'E. 21st St.'; % 02
    'Downtown'; % 03
    'Greenwood'; % 04
    'W. 79th St.'; % 05
    'Lambert'; % 06
    'Wayne Twp Comm'; % 07
    'Noblesville'; % 08
    'Greenfield'; % 09
    'Greenfield Park'; % 10
    'Butler Univ.'; % 11
    'Shortridge Rd.'; % 12
    'Pleasant View'; % 13
    'Crawfordsville'}; % 14


clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"

site_names = dir(fullfile(readFolder,city,'site*'));

site.date_issued = date_issued; % This date will be updated with the most recent date in the files below.
site.date_issued_str = date_issued_str; % This date will be updated with the most recent date in the files below.

for i = 1:length(site_names)

site.codes{1,i} = site_names(i).name;
fprintf('Reading header info for site %s.\n',site.codes{1,i})

site.(site.codes{i}).name = site_names(i).name;
site.(site.codes{i}).code = upper(site_names(i).name);

site.(site.codes{i}).files = dir(fullfile(readFolder,city,site.codes{1,i},'*.dat'));

% Find the number of inlet heights.
all_inlets = {};
for j = 1:length(site.(site.codes{i}).files)
    underscores_ind = regexp(site.(site.codes{i}).files(j).name,'_');
    %dat_ind = regexp(site.(site.codes{i}).files(j).name,'.dat');
    all_inlets{j,1} = site.(site.codes{i}).files(j).name(underscores_ind(end-1)+1:underscores_ind(end)-1);
end
clear dat_ind underscores_ind
site.(site.codes{i}).inlet_height_long_name = unique(all_inlets)';

for j = 1:length(site.(site.codes{i}).inlet_height_long_name)
    site.(site.codes{i}).inlet_height{1,j} = str2double(site.(site.codes{i}).inlet_height_long_name{1,j}(1:end-1));
end

% Open the first file & extract site info from the header
fid = fopen(fullfile(site.(site.codes{i}).files(1).folder,site.(site.codes{i}).files(1).name));
header_lines = 0;
readNextLine = true;
while readNextLine==true
    tline = fgets(fid);
    header_lines = header_lines+1;
    if ~isempty(regexp(tline,'DATA VERSION:','once'))
        site.(site.codes{i}).date_issued = datetime(strip(tline(regexp(tline,':')+1:end)),'InputFormat','yyyyMMdd');
        site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
        site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
    end
    if ~isempty(regexp(tline,'STATION NAME:','once'))
        site.(site.codes{i}).long_name = [strip(tline(regexp(tline,':')+1:end)),' - ',site_full_names{i,1}];
    end
    if ~isempty(regexp(tline,'LATITUDE:','once'))
        site.(site.codes{i}).in_lat = str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'LONGITUDE:','once'))
        site.(site.codes{i}).in_lon = -str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'ALTITUDE:','once'))
        site.(site.codes{i}).in_elevation = str2double(tline(regexp(tline,'[0-9.]')));
    end

    if ~isempty(regexp(tline,'PARAMETER:','once'))
        slash_ind = regexp(tline,'/');
        formatSpec = [];
        for j = 1:length(slash_ind)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        
        sp = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter','/','CollectOutput',1);
        sp = sp{1};
        for j = 1:length(sp)
            sp{1,j} = lower(strip(sp{1,j}));
        end
        site.(site.codes{i}).species = sp;
        
        clear sp formatSpec slash_ind
    end

    if ~isempty(regexp(tline,'MEASUREMENT UNIT:','once'))
        formatSpec = [];
        for j = 1:length(site.(site.codes{i}).species)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        units = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter',',','CollectOutput',1);
        units = units{1};
        flag = true(size(units));
        for j = 1:length(units) % just keep ppm or ppb
            units{1,j} = units{1,j}(regexp(units{1,j},'[ppmb]'));
            if isempty(units{1,j}); flag(1,j) = false; end
        end
        units = units(flag);
        
        site.(site.codes{i}).species_units_long_name = units;
        site.(site.codes{i}).species_units = cell(size(site.(site.codes{i}).species_units_long_name));
        for j = 1:length(site.(site.codes{i}).species_units_long_name)
            if strcmp(site.(site.codes{i}).species_units_long_name{1,j},'ppb')
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
            elseif strcmp(site.(site.codes{i}).species_units_long_name{1,j},'ppm')
                site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
            end
        end
        for j = 1:length(site.(site.codes{i}).species)
            if strcmp(site.(site.codes{i}).species{1,j},'co2')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
                site.(site.codes{i}).species_long_name{1,j} = 'carbon_dioxide';
            elseif strcmp(site.(site.codes{i}).species{1,j},'ch4')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
                site.(site.codes{i}).species_long_name{1,j} = 'methane';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
                site.(site.codes{i}).species_long_name{1,j} = 'carbon_monoxide';
            end
        end

        clear units flag formatSpec
    end
    if ~isempty(regexp(tline,'MEAUREMENT METHOD:','once'))
        for j = 1:length(site.(site.codes{i}).species_units)
            site.(site.codes{i}).instrument{1,j} = strip(tline(regexp(tline,':')+1:end));
        end
    end
    
    %if ~isempty(regexp(tline,'PLEASE DO NOT DISTRIBUTE THESE DATA','once')); readNextLine = false; end % This was the end of the first version of the data
    if ~isempty(regexp(tline,'UNCERTAINTY:','once')); readNextLine = false; end
end
fclose(fid);
site.(site.codes{i}).header_lines = header_lines+6;
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Indianapolis'; % use timezones to find out the available time zone designations.
end



site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

site.reference = 'Richardson, Scott J., Natasha L. Miles, Kenneth J. Davis, Thomas Lauvaux, Douglas K. Martins, Jocelyn C. Turnbull, Kathryn McKain, Colm Sweeney, and Maria Obiminda L. Cambaliza. �Tower Measurement Network of In-Situ CO2, CH4, and CO in Support of the Indianapolis FLUX (INFLUX) Experiment.� Elem Sci Anth 5, no. 0 (October 19, 2017). https://doi.org/10.1525/elementa.140.';

% Loading the data

for i = 1:length(site.codes)
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
            
            for fn = 1:length(site.(site.codes{i}).files)
                % If the file isn't for the correct inlet height, go to the next file. 
                if ~contains(site.(site.codes{i}).files(fn).name,intxt); continue; end
                
                % All of Indy's sites have columns for CO2, CH4, CO, even if there is no data in those columns! 
                % Make formatSpec based on the number of species.
%                 formatSpec = '%s%s%f%f%f%f%f%f';
%                 for j = 1:length(site.(site.codes{i}).species)
%                     formatSpec = [formatSpec,'%f%f%f']; %#ok<AGROW>
%                 end
%                 formatSpec = [formatSpec,'%f%f']; %#ok<AGROW>
                formatSpec = '%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';

                % Read the data file after skipping the header lines.
                fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).header_lines,'CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                
                % All of Indy's sites have columns for CO2, CH4, CO, even if there is no data in those columns! 
                %col.species = 7+(sp-1)*3;
                %col.std = 8+(sp-1)*3;
                if strcmp(sptxt,'co2'); col.species = 7; col.std = 8; col.unc = 9; end
                if strcmp(sptxt,'ch4'); col.species = 10; col.std = 11; col.unc = 12; end
                if strcmp(sptxt,'co'); col.species = 13; col.std = 14; col.unc = 15; end
                col.n = 16; % n is common to all of the species.
                
                % Col 17 is the QC flag.  Only use data that has col 17==1. 
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.species)]; % species 
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.std)]; % species std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.n)]; % species n
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_unc']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.unc)]; % species uncertainty
                
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
                    datetime(read_dat{1,2}(read_dat{1,2}(:,17)==1,4),ones(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1),read_dat{1,2}(read_dat{1,2}(:,17)==1,5),read_dat{1,2}(read_dat{1,2}(:,17)==1,6),zeros(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1),zeros(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1))]; % time
                clear col
                fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
            end
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
            clear data_range_ind
            
            if isempty(site.(site.codes{i}).([sptxt,'_',intxt])) % If there is no data (ie if there is no CH4 data but there is CO2 & CO data), remove the site/inlet/species.
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt]);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_std']);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_n']);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_time']);
                continue
            end
            
            
            % Indianapolis does not currently have 'n' in their data files so this needs to be manually entered currently. 
            %site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set. 
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Set fill values:
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_unc']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lat']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lon']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']))) = -1e34;
            
            site.groups = [site.groups; {[site.(site.codes{i}).code,'_',sptxt,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
    fprintf('---- %-6s complete ----\n\n',site.codes{i})
end

%% Custom QAQC based on discussion with Tasha Aug 2019

%return
fprintf('*** Custom QAQC requested by Tasha Miles in Aug 2019***\n')
fprintf('Remove the 307.3 ppm CO2 point at Site 10 (40m inlet) on Aug 16, 2013\n')

i = find(strcmp(site.codes,'site10')); %site.(site.codes{i})
inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'40M')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
sp = find(strcmp(site.(site.codes{i}).species,'co2')); sptxt = site.(site.codes{i}).species{sp};
tmp_dt = site.(site.codes{i}).([sptxt,'_',intxt,'_time']);
tmp_dat = site.(site.codes{i}).([sptxt,'_',intxt]);
tmp_dat(tmp_dat==-1e34) = nan;
% figure(99);clf; plot(tmp_dt,tmp_dat);
mask = find(and(tmp_dat<310,and(tmp_dt>datetime(2013,08,16),tmp_dt<datetime(2013,08,17))));
site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -1e34;

fprintf('Remove the -1008 ppb CO points at Site 03 (54m inlet) on June 8, 2012.\n')
i = find(strcmp(site.codes,'site03')); %site.(site.codes{i})
inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'54M')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
sp = find(strcmp(site.(site.codes{i}).species,'co')); sptxt = site.(site.codes{i}).species{sp};
tmp_dt = site.(site.codes{i}).([sptxt,'_',intxt,'_time']);
tmp_dat = site.(site.codes{i}).([sptxt,'_',intxt]);
tmp_dat(tmp_dat==-1e34) = nan;
% figure(99);clf; plot(tmp_dt,tmp_dat);
mask = find(and(tmp_dat<-1000,and(tmp_dt>datetime(2012,06,08),tmp_dt<datetime(2012,06,09))));
site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -1e34;

%% Identify the netCDF files to create based on species.

site.unique_species = unique(site.species);
site.species_list = [];
for species_ind = 1:length(site.unique_species)
    site.species_list = [site.species_list, site.unique_species{species_ind},' '];
end
site.species_list = strip(site.species_list); % Removes the last space

for j = 1:length(site.unique_species)
    if strcmp(site.unique_species{j,1},'co2')
        site.unique_species_long_name{j,1} = 'carbon dioxide';
    elseif strcmp(site.unique_species{j,1},'ch4')
        site.unique_species_long_name{j,1} = 'methane';
    elseif strcmp(site.unique_species{j,1},'co')
        site.unique_species_long_name{j,1} = 'carbon monoxide';
    end
end

%% Creating the netCDF file

eval('co2usa_create_netCDF')

%% Convert the netCDF data to text files.

fprintf('Now creating the text files from the netCDF files.\n')
netCDF2txt_group = 'all_sites';
eval('co2usa_netCDF2txt')


