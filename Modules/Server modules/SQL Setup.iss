[Files]
// Install batch script to collect instance names
Source: "{#SourcePath}\Input\scripts\Instances.bat"; DestDir: "{app}";


[Code]

var
  OSQL_PATH=String;

procedure SQLSetup();
begin

  //Some initial checks are required to determine the wizard flow relating   
  //to the SQL install

  OSQL_PATH := FileSearch('osql.exe', GetEnv('PATH'));

  Log('Location of OSQL.EXE is ' + OSQL_PATH + ' (Initial Checks)');
  if OSQL_PATH = '' then begin
    //Detect SQL Servers available to install

    SQL_NEEDED := true;
    SQLEXPRESSNAME := '';

    //try SQL2014 first
    if dirExists(ExpandConstant('{src}\SQL2014')) then begin
      SQLEXPRESSNAME := 'SQL2014';
      Log(SQLEXPRESSNAME + ' folder found, this will be installed.');
    end
    else begin
      //SQL2012 next
      if dirExists(ExpandConstant('{src}\SQL2012')) then begin
        SQLEXPRESSNAME := 'SQL2012';
        Log(SQLEXPRESSNAME + ' folder found, this will be installed.');
      end
      else begin
        //try SQL2008R2
        if dirExists(ExpandConstant('{src}\SQL2008R2')) then begin
          SQLEXPRESSNAME := 'SQL2008R2';
          Log(SQLEXPRESSNAME + ' folder found, this will be installed.');
        end
        else begin
          //SQL2005
          if dirExists(ExpandConstant('{src}\SQL2005')) then begin
            SQLEXPRESSNAME := 'SQL2005';
            Log(SQLEXPRESSNAME + ' folder found, this will be installed.');
          end
          else begin
          //MSDE finally
            if dirExists(ExpandConstant('{src}\MSDE2000')) then begin
              SQLEXPRESSNAME := 'MSDE2000';
              Log(SQLEXPRESSNAME + ' folder found, this will be installed.');
            end
            else begin
              Log('"ERROR: MSDE not found - cannot install server without SQL (Expected in folder {src}\MSDE2000');
              SQLEXPRESSNAME := '';
              if UNATTENDED = false then begin
                if COMPONENTS = 'B' then begin
                  Abort();
                end;
              end;
            end;
          end;
        end;
      end;
    end;
      // If SQL2014 already detected, then no more additional checks.       
      //Otherwise, check if we can use SQL Server 2016
      
    if SQLEXPRESSNAME <> 'SQL2014' then begin
      //If SQL2016 available and 64bit and not Windows 7 then use it instead
      if dirExists(ExpandConstant('{src}\SQL2016')) then begin
        if OS = 64 then begin
          if OPERATING_SYSTEM >= 6.2 then begin
            SQLEXPRESSNAME := 'SQL2016';
            Log('"Folder SQL2016 found, so this will be installed instead.');
          end;
        end;
      end;
    end;

    Log('SQL server folders parsed, SQL server to install=' + SQLEXPRESSNAME + ', Architecture=' + OS + ', Windows version=' + WINDOWS_VERSION + ', OS ver=' + OPERATING_SYSTEM);

    SQLEXPRESSFULLNAME := SQLEXPRESSNAME;

    if SQLEXPRESSNAME <> 'MSDE2000' then begin
      SQLEXPRESSFULLNAME := SQLEXPRESSNAME + ' Express';
    end;
    Log('SQLEXPRESSNAME = ' + SQLEXPRESSNAME);

    //Check if the system needs Windows updates before runing Enabler install
    //Windows 8.1 64 bit  & Windows Server 2012 require updates before SQL2016 installed

    if OPERATING_SYSTEM = 6.3 then begin
      if OS = 64 then begin
        if SQLEXPRESSNAME = 'SQL2016' then begin
          Log('Checking SQL2016 requirements for Windows 8.1 or Server 2012  64 bit');
          Exec('C:\WINDOWS\Sysnative\CMD.EXE', '/C wmic qfe get HotFixId | find "KB2919355"', '', SW_SHOW, ewwaituntilterminated,ResultCode);
          KB_FIND1 := ResultCode;
          Log('Result of Windows update finds ' + KB_FIND1);
          if KB_FIND1 = 1 then begin
            MsgBox('Requirements for SQL2016 not met');
            Log('Windows 8.1 or Server 2012 requires system updates to install SQL2016 (KB2919355). Please remove the SQL2016 folder from the source folder, or perform a system update.');
            Abort();
          end;
        end;
      end;
    end;
  end;
  else begin
    
    //OSQL has been found, SQL server already installed

    SQL_NEEDED := false; 
    if SILENT = false then begin
    //display progress message
    end;

    //If no instance has been passed by the command line 
    if CMD_INSTANCE = '' then begin
      //GET LIST OF NAMED INSTANCES
      //Server SQL settings

      //Get temporary filename into INSTANCES
      INSTANCES := 'temporary.tmp';
      if OS=64 and OPERATING_SYSTEM >= 6 then begin
        Exec('C:\WINDOWS\Sysnative\CMD.EXE', '/C '+ ExpandConstant('{app}\Instances.bat') + ' ' + ExpandConstant('{tmp}\')+INSTANCES, '', SW_SHOW, ewwaituntilterminated,ResultCode);
      end
      else begin
        Exec('CMD.EXE', '/C '+ ExpandConstant('{app}\Instances.bat') + ' ' + ExpandConstant('{tmp}\')+INSTANCES, '', SW_SHOW, ewwaituntilterminated,ResultCode);
      end;

      if ResultCOde <> 0 then begin
        Log('Unable to get SQL Instance Name registry key.' + ResultCode);
        INSTANCE_NAME_NEEDED := true;
      end
      else begin
        LINE := '';
        NAME := '';
        SQL_INSTANCES := '';

        LoadStringFromFile(ExpandConstant('{tmp}\')+LINE);

        NAME := LINE;

        if pos('MSSQLSERVER',NAME) <> 0 and INSTANCE_NAME_NEEDED = true then begin
          INSTANCE_NAME_NEEDED = FALSE;
        end
        else begin
          if pos('SQLEXPRESS', NAME) <> 0 and pos('MSSQLSERVER', NAME) <> 0 and INSTANCE_NAME_NEEDED = true then begin
            SQL_INSTANCE := SQLEXPRESS;
            SQLQUERY := PC_NAME+'\'+SQL_INSTANCE;
            INSTANCE_NAME_NEEDED = FALSE;
          end;
          //Build list of instances names incase they need to be displayed
          SQL_INSTANCES := NAME+CRLF;
        end;

        Log('SQL Instance Names found '+CRLF+SQL_INSTANCES);

        //Check if we found a known instance, if we haven't do we have a list of instances
        if INSTANCE_NAME_NEEDED = TRUE AND SQL_INSTANCES <> '' then begin
          //We have fouind instance names, if we haven't found a default one we need to display the list
          INSTANCE_NAME_LIST = TRUE;
        END;
      END;

      if SQL_INSTANCES = '' then begin
        Log('No SQL Instance names found');
      end;

      //if we found no available instances

      if INSTANCE_NAME_LIST <> TRUE and INSTANCE_NAME_NEEDED = TRUE THEN BEGIN
      
      //OSQL DETECT DEFAULT SQL NAMED INSTANCES
      //Execute the sql to get the verify the instance name of the default instance or the instance name passed by the command line

      Log('Query database to check instance name '+SQLQUERY);
      Exec(OSQL_PATH+'\OSQL.EXE', '-b -d master -E -S'+SQLQUERY+ ' -Q "select count(*) from sysobjects"','',SW_SHOW,ewwaituntilterminated, ResultCode);

      if ResultCode <> 0 then begin
        Log(SQLQUERY+ ' database instance does not exist or the SQL server is not configured correctly the osql query failed.');
        
        //try again with a different instance name
        
        SQL_INSTANCE := SQLEXPRESS;
        SQLQUERY := PC_NAME+'\'+SQL_INSTANCE;
        Log('Query database to check instance name '+SQLQUERY);
        Exec(OSQL_PATH+'\OSQL.EXE', '-b -d master -E -S'+SQLQUERY+ ' -Q "select count(*) from sysobjects"','',SW_SHOW,ewwaituntilterminated, ResultCode);
 
        if ResultCode <> 0 then begin
          SQL_INSTANCE := '';
          Log(SQLQUERY+ ' database instance does not exist or the SQL server is not configured correctly the osql query failed.');
          INSTANCE_NAME_NEEDED := TRUE;
        end
        else begin
          INSTANCE_NAME_NEEDED := FALSE;
        end;
      end
      else begin
        INSTANCE_NAME_NEEDED := FALSE;
      end;
    end;
  end;

  //Get available SQL servers for client install
  //Wise script does not actually do this, it's commented out


  //Check if the source media is located in a network drive
  if SQLEXPRESSNAME <> '' then begin
    if INST_DRIVE = '\\' then begin
      //If the installer is being run from a network location (UNC name) then we cannot install SQL2005
      if UNATTENDED = false then begin
        msgbox('Cannot install '+SQLEXPRESSNAME+'from UNC path',mbinformation,MB_OK);
      end;
      Log('Cannot install '+SQLEXPRESSNAME+'from UNC path');
      Abort();
    end;
  end;
end;


      
      
      
      
       
