function ufd_convertXML(filename)
% This function converts the OpenCV XML file to a MATLAB data file with the same information inside.
% (Based on code by D. Kroon)

%Example
% filename='haarcascade_lips';
% ufd_convertXML(filename);
%
%
%Function is written by Bruno Ricardo Scherer based in D.Kroon University of 16/02/2016.

%Checking and removing the end of the filename

%Array of position of dotes
j = find(filename=='.');

%Remove the final of name
if(~isempty(j))
	filename = filename(1:j-1);
end

%Open the data .XML mode read
fid = fopen([filename '.xml'], 'r');
c = fread(fid, inf, 'char=>char')';  %Be careful with the syntax . Matrix transposed
fclose(fid);


%%%%%%%%%%%%%%%%%%xml conversion matla / octave%%%%%%%%%%%%%%%%%%%%%%%%%
c(c==13)=[];
c(c==10)=[];
fl = regexp(c, '<', 'split');

%Open file .m in mode of write
fid = fopen([filename '.m'], 'w');

h=0; nw=0;
infoname=cell(1,10);
infocount=zeros(1,10);
for i=2:length(fl)
    str=fl{i};
    if(length(str)>1), st=str(1);  else st=''; end
    switch(st)
        case {'!','','?'}
            continue
        case '/'
            t=find(str=='>',1,'first');
            name=str(2:t-1);
            infocount(h)=0;
            h=h-1;
            continue
        otherwise
            t1=find(str=='>',1,'first');
            t2=find(str(1:t1-1)==' ');
            if(~isempty(t2))
                t=t2;
            else
                t=t1;
            end
            name=str(1:t-1);
            
            data=str(t+1:end);
            h=h+1;
            if(name=='_')
                infocount(h-1)=infocount(h-1)+1;
                name='value';
            end
            infoname{h}=name;
            while(~isempty(data)&&(data(1)==' ')); data=data(2:end); end
            while(~isempty(data)&&(data(end)==' ')); data=data(1:end-1); end
    end
    if(~isempty(data))
        in='';
        for j=1:h
            if(infocount(j)>0)
                count=['(' num2str(infocount(j)) ')'];
            else
                count='';
            end
            
            if(j==1)
                in=[infoname{j} count];
            else
                in=[in '.' infoname{j} count];
            end
        end
        in=strrep(in,'.value.','.');
        num=str2num(data);
        if(~isempty(num))
            if(length(num)==1)
                str=[in ' = ' data ';'];
            else
                str=[in ' = [' data '];'];
            end
        else
            str=[in ' = ''' data ''';'];
        end
        nw=nw+1;
        if(nw==1), str=['%' str]; end
        fprintf(fid,'%s\r\n',str);
        if(nw>1)
            eval(str)
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Close the file "fid"
fclose(fid);

%Save the data in .mat
save([filename '.mat'],'opencv_storage');
