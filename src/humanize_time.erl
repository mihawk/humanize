-module(humanize_time).
-author('chan sisowath').
%% port to erlang https://github.com/dustin/go-humanize/blob/master/times.go
-export([relTime/4]).

-define(Minute,    60).
-define(Hour,      60 * ?Minute).
-define(Day,       24 * ?Hour).
-define(Week,       7 * ?Day).
-define(Month,     30 * ?Day).
-define(Year,      12 * ?Month).
-define(LongTime,  37 * ?Year).

-record(magnitude,{d,format,divby}).
-record(fmt,{pre=false, txt, append=false}).
-define(Magnitudes, [
	#magnitude{d=1,              format=#fmt{         txt="now"},                       divby=1},
	#magnitude{d=2,              format=#fmt{         txt="1 second ",    append=true}, divby=1},
	#magnitude{d=?Minute,        format=#fmt{pre=true,txt="~B seconds ",  append=true}, divby=1},
	#magnitude{d=2 * ?Minute,    format=#fmt{         txt="1 minute ",    append=true}, divby=1},
	#magnitude{d=?Hour,          format=#fmt{pre=true,txt="~B minutes ",  append=true}, divby=?Minute},
	#magnitude{d=2 * ?Hour,      format=#fmt{         txt="1 hour ",      append=true}, divby=1},
	#magnitude{d=?Day,           format=#fmt{pre=true,txt="~B hours ",    append=true}, divby=?Hour},
	#magnitude{d=2 * ?Day,       format=#fmt{         txt="1 day ",       append=true}, divby=1},
	#magnitude{d=?Week,          format=#fmt{pre=true,txt="~B days ",     append=true}, divby=?Day},
	#magnitude{d=2 * ?Week,      format=#fmt{         txt="1 week ",      append=true}, divby=1},
	#magnitude{d=?Month,         format=#fmt{pre=true,txt="~B weeks ",    append=true}, divby=?Week},
	#magnitude{d=2 * ?Month,     format=#fmt{         txt="1 month ",     append=true}, divby=1},
	#magnitude{d=?Year,          format=#fmt{pre=true,txt="~B months ",   append=true}, divby=?Month},
	#magnitude{d=18 * ?Month,    format=#fmt{         txt="1 year ",      append=true}, divby=1},
	#magnitude{d=2 * ?Year,      format=#fmt{         txt="2 years ",     append=true}, divby=1},
	#magnitude{d=?LongTime,      format=#fmt{pre=true,txt="~B years ",    append=true}, divby=?Year},
	#magnitude{d=10 *?LongTime,  format=#fmt{         txt="a long while ",append=true}, divby=1}]).

search(Diff, [L])   -> L;
search(Diff, [H|R]) when H#magnitude.d < Diff ->  search(Diff, R);
search(Diff, [H|R]) when H#magnitude.d > Diff ->  H.

relTime(Date, Comparison, Albl, Blbl) ->

 Diff = calendar:datetime_to_gregorian_seconds(Comparison) - calendar:datetime_to_gregorian_seconds(Date),
 Label = case Diff of Diff when Diff < 0 -> Blbl; _ -> Albl end,
 Mag = search(abs(Diff), ?Magnitudes),
 #magnitude{format=Fmt} = Mag,
 A = case Fmt#fmt.pre of 
 	true -> io_lib:format(Fmt#fmt.txt,[round(Diff/Mag#magnitude.divby)]);
 	_ -> Fmt#fmt.txt end, case Fmt#fmt.append of true -> A ++ Label; _ -> A end.

%%TODO: write test.