classdef Logger < handle
    properties(Access = private)
        fileID
        headline=[];
    end

    methods
        function this = Logger(filename)
            this.fileID = fopen(filename, 'a');
            assert(this.fileID ~= -1, 'Could not open log file %s', filename);
        end

        function delete(this)
            fclose(this.fileID);
        end

        function write(this, format, varargin)
            fprintf(this.fileID, strcat(datestr(now), ': ', format, '\n'), varargin{:});
        end
        function newline(this)
            fprintf(this.fileID,"######################################################\n");
        end
        function progress_inc(this)
            fprintf(this.fileID,'/');
        end
        function progress_start(this)
            fprintf(this.fileID,'Progress:');
        end
        function progress_end(this)
            fprint(this.fileID,'\n');
        end
    end
end