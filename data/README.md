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
	<li>VariableID: the id we have given the variable</li>
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
