//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 27/04/2023
//******************************************************************************************
//@description : Wrapper Class to handle Service Area requests by Place Id
public with sharing class RG_AddressByPlaceIdPayload
{
	public class Geometry {
		public Location location;
	}

	public List<Results> results;
	public String status;

	public class Results {
		public Geometry geometry;
	}

    public class Location {
		public Double lat;
		public Double lng;
	}
}