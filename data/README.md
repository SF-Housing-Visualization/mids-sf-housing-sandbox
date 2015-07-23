# Structure

Directory structure for production data looks like this:

	data/prod/
		data_variables.csv
		data_geos.csv
		values/
			GroupA.csv
			GroupB.csv
			...

This is the sructure of the data that the visualizaiton will ultimately use. We need to get our data in to this format.

<code>data_geos.csv</code> describes the geographical information.

<code>data_variables.csv</code> describes all the variables we have.

<code>values/*.csv</code> actually has the values for all the variables.

## data_variables.csv

This contains information about each variable used in our visualization

<ol>
	<li>GroupID: the group the variable is in - this corresponds to csv file this variable is in <code>values/GroupID.csv</code></li>
	<li>GroupName: pretty group name in case we want to display it to users</li>
	<li>VariableID: the id we have given the variable, this corresponds to the column of the variable in it's <code>GroupID.csv</code> file</li>
	<li>VariableName: the name of the variable as we want it to appear in the visualizaiton</li>
	<li>VariableDescription: longer explanation of the variable as it will appear in the explanatory text</li>
</ol>

## data_geos.csv

This contains information about each geographic location

<ol>
	<li>GeoID: this corresponds to Id2 from the census data, like 6001</li>
	<li>LongID: this corresponds to Id1 form the census data, 0500000US06001</li>
	<li>LongName: this corresponds to Geography from the census data, like "Alameda County, California"</li>
	<li>ShortName: this the geography name as we want it displayed in th viz, like "Alameda"</li>
</ol>

## values/*.csv

These files contain the actual values for each GroupID.

<ol>
	<li>GeoID: this corresponds to Id2 from the census data, like 6001 and used to look up the Geo in data_geos.csv</li>
	<li>Date: format mm/dd/yyyy - not really my preferred format but when you edit a csv in excel it saves it like this, so much more convenient for now. I've been putting years as 12/31/yyyy</li>
	<li>Variable1</li>
	<li>Variable2</li>
	<li>...</li>
	<li>VariableN: these correspond to the VariableID in the <code>data_variables.csv</code> file</li>
</ol>
