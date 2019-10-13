/*****************************************************************
 *
 * Implementation of PumpManagerX::App Class
 *
 * Copyright (C) 2017 Integration Technologies Limited
 * All rights reserved.
 *
 * Created 01/06/2011
 * 
 ******************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Xamarin.Forms;

namespace PumpManagerX
{
	public partial class App : Application
	{
		public App ()
		{
			InitializeComponent();

			MainPage = new PumpManagerX.MainPage();
		}

		protected override void OnStart ()
		{
			// Handle when your app starts
		}

		protected override void OnSleep ()
		{
			// Handle when your app sleeps
		}

		protected override void OnResume ()
		{
			// Handle when your app resumes
		}
	}
}
