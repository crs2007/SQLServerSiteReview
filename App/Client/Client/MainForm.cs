using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Linq;

namespace Client
{
    public partial class MainForm :Form
    {
       String cs = @"Password=Sr@12345^;Persist Security Info=True;User ID=SiteReviewApp;Initial Catalog=SiteReviewUser;Data Source=yellow.database.windows.net; Connect Timeout=30";
       String cs_TestServer = "";
        public int ClientID ;
       private bool _Success;
       private bool _Cancel;
       private string PreScript;
       private string Script;
       public string Client;
       public bool Allow_Week_Password_Check;
       public bool Debug;
       public bool Display;
       public string MessageOutput;
       public DataSet  XML_dataSet = new DataSet();
       public string strXML="";
       private int Progress;
       List<BackgroundWorker> ArrBackgroundWorker = new List<BackgroundWorker>();
       public static ConcurrentDictionary<string, SqlCommand> Dictionary_Cmd = new ConcurrentDictionary<string, SqlCommand>();
   
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }
        public MainForm()
        {
            InitializeComponent();
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.ResumeLayout(false);
           
        }
        private void MainForm_Load(object sender, EventArgs e)
        {
            //When the main form is loading, show the login form
            frmLogin frm = new frmLogin();
            frm.ShowDialog();
            ClientID = frm.ClientID;
            Disable_Buttons();
            ResizeForm();
            txtTitleReport.Text = "General Client";
            txtXML.ConfigurationManager.Language = "xml";
            Progress = 0;
        }

        private void btnTestConnection_Click(object sender, EventArgs e)
        {
            this.Cursor = Cursors.WaitCursor;
            DbConnection DBConnTest;

            if (chkBox_Intergrated.Checked== true)
            {
                DBConnTest = new SqlConnection("Server=" + txtServerName.Text + "; Database=master;Trusted_Connection=true");
            }
            else
            {
                DBConnTest = new SqlConnection("Server=" + txtServerName.Text + ";User ID="+txtLogin.Text+";Password="+txtPassword.Text+";Database=master;Trusted_Connection=false");
            }

                
            try
            {
                DBConnTest.Open();
                MessageBox.Show("\nTest Successful\n");
                cs_TestServer = DBConnTest.ConnectionString;
                btnRunScript.Enabled = true;
                btnStop.Enabled = false;
                btn_SendXML2Naya.Enabled = false;
                btnSaveXML.Enabled = false;
                _Success = false;

            }
            catch (Exception exception)
            {
                MessageBox.Show("Test Failed Exception Thrown: " + exception.Message);
            }
            finally
            {
                DBConnTest.Close();
            }

            this.Cursor = Cursors.Default;

        }
       

        private void btnSaveXML_Click(object sender, EventArgs e)
        {

            using (var sfd = new SaveFileDialog())
            {
                sfd.Filter = "XML files (*.xml)|*.xml|All files (*.*)|*.*";
                sfd.FilterIndex = 1;

                if (sfd.ShowDialog() == DialogResult.OK)
                {
                    File.WriteAllText(sfd.FileName, txtXML.Text);
                }
            }

            
        }

        private void chkBox_Intergrated_CheckedChanged(object sender, EventArgs e)
        {
            if (chkBox_Intergrated.Checked == true)
                {
                    txtLogin.Enabled = false;
                    txtPassword.Enabled = false;
                    lblLogin.Enabled = false;
                    lblPassword.Enabled = false;
                }
            else
                {
                    txtLogin.Enabled = true;
                    txtPassword.Enabled = true;
                    lblLogin.Enabled = true;
                    lblPassword.Enabled = true;

                }
            Disable_Buttons();
        }

        private void btn_SendXML2Naya_Click(object sender, EventArgs e)
        {
            try
            {
                this.Cursor = Cursors.WaitCursor;
                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs);

                SqlCommand myCommand = default(SqlCommand);

                myCommand = new SqlCommand("[GUI].[usp_InsertXMLReport] @XMLData,@ClientID", myConnection);

                SqlParameter uXMLData = new SqlParameter("@XMLData", SqlDbType.Xml);
                SqlParameter uClientID = new SqlParameter("@ClientID", SqlDbType.Int);



                uXMLData.Value = txtXML.Text;
                uClientID.Value = ClientID;
                //uClientID.Value = 10;

                myCommand.Parameters.Add(uXMLData);
                myCommand.Parameters.Add(uClientID);
                

                myCommand.Connection.Open();

                SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                 
                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }
                this.Cursor = Cursors.Default;
                MessageBox.Show("You Send XML in successfully. Thanks. ");
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                
            }
        }

        public void SendToExecute()
        {
            _Cancel = false;
            _Success = true;
            try
            {
                
                BackgroundWorker backgroundWorker = new BackgroundWorker();
                backgroundWorker.WorkerSupportsCancellation = true;
                backgroundWorker.DoWork += new DoWorkEventHandler(BackgroundWorker_DoWork_Step1_GetScript);
                backgroundWorker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(BackgroundWorker_RunWorkerCompleted_Step1_GetScript);
                ArrBackgroundWorker.Add(backgroundWorker);
                InsertLine2TxtOutput("Start: Get Scripts from Naya's Server");
                backgroundWorker.RunWorkerAsync(1);
               
            }
            catch
            {
                _Success = false;
            }
        }

        private void BackgroundWorker_DoWork_Step1_GetScript(object sender, DoWorkEventArgs e)
        {
            try
            {
                var index = e.Argument.ToString();
                e.Result = index;
              
                //here code that he need doing
                //Step 1 

                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs);
                SqlCommand myCommand = default(SqlCommand);
                myCommand = new SqlCommand("[GUI].[usp_GetClientScript] @PreScript output,@Script output", myConnection);
                SqlParameter uPreScript = new SqlParameter("@PreScript", SqlDbType.NVarChar,-1) { Direction = ParameterDirection.Output };
                SqlParameter uScript = new SqlParameter("@Script", SqlDbType.NVarChar,-1 ) { Direction = ParameterDirection.Output };
                myCommand.Parameters.Add(uPreScript);
                myCommand.Parameters.Add(uScript);
                Dictionary_Cmd.TryAdd(myCommand.CommandText, myCommand);
                myCommand.Connection.Open();

                SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                PreScript = uPreScript.Value.ToString();
                Script = uScript.Value.ToString();

                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }

                 
                
                
                // System.Threading.Thread.Sleep(10000);
 


            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                MessageOutput = MessageOutput + "\n" + "Exception:" + ex.Message;  
                e.Cancel = true;
            }
        }
        private void BackgroundWorker_RunWorkerCompleted_Step1_GetScript(object sender, RunWorkerCompletedEventArgs e)
        {
            txtOutput.Text = MessageOutput;

            if (e.Error == null && !e.Cancelled)
            {
                try
                {
                    InsertLine2TxtOutput("End: Get Scripts from Naya's Server");
                    txtOutput.Text = Script;

                    try
                    {
                        BackgroundWorker backgroundWorker = new BackgroundWorker();
                        backgroundWorker.WorkerSupportsCancellation = true;

                        backgroundWorker.DoWork += new DoWorkEventHandler(BackgroundWorker_DoWork_Step2_RunPreScript);
                        backgroundWorker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(BackgroundWorker_RunWorkerCompleted_Step2_RunPreScript);
                        
                        ArrBackgroundWorker.Add(backgroundWorker);
                        InsertLine2TxtOutput("Start: Pre Script... ");
                        backgroundWorker.RunWorkerAsync(2);
                    }
                    catch
                    {
                        btnRunScript.Enabled = true;
                        btnStop.Enabled = false;
                        btn_SendXML2Naya.Enabled = false;
                        btnSaveXML.Enabled = false;
                        toolStripProgressBar1.Value = 0;
                        timer1.Enabled = false;
                        _Success = false;
                    }

                }
                catch
                {
                    btnRunScript.Enabled = true;
                    btnStop.Enabled = false;
                    btn_SendXML2Naya.Enabled = false;
                    btnSaveXML.Enabled = false;
                    toolStripProgressBar1.Value = 0;
                    timer1.Enabled = false;
                    _Success = false;
                }

            }
            else
            {
                btnRunScript.Enabled = true;
                btnStop.Enabled = false;
                btn_SendXML2Naya.Enabled = false;
                btnSaveXML.Enabled = false;
                toolStripProgressBar1.Value = 0;
                timer1.Enabled = false;
                _Success = false;
            }
        }

        private void BackgroundWorker_DoWork_Step2_RunPreScript(object sender, DoWorkEventArgs e)
        {
            try
            {
                var index = e.Argument.ToString();
                e.Result = index;
                //here code that he need doing
                //Step 1 

                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs_TestServer);
                SqlCommand myCommand = default(SqlCommand);
                myCommand = new SqlCommand(PreScript, myConnection);
                Dictionary_Cmd.TryAdd(PreScript, myCommand);
                myCommand.Connection.Open();

                SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }

             


                // System.Threading.Thread.Sleep(10000);



            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                MessageOutput = MessageOutput + "\n" + "Exception:" + ex.Message;  
                e.Cancel = true;
            }
        }
        private void BackgroundWorker_RunWorkerCompleted_Step2_RunPreScript(object sender, RunWorkerCompletedEventArgs e)
        {
            txtOutput.Text = MessageOutput;




            if (e.Error == null && !e.Cancelled)
            {
                try
                {
                    InsertLine2TxtOutput("End: Pre Script... ");
                    try
                    {
                        BackgroundWorker backgroundWorker = new BackgroundWorker();
                        backgroundWorker.WorkerSupportsCancellation = true;

                        backgroundWorker.DoWork += new DoWorkEventHandler(BackgroundWorker_DoWork_Step3_BuildScript);
                        backgroundWorker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(BackgroundWorker_RunWorkerCompleted_Step3_BuildScript);
                        ArrBackgroundWorker.Add(backgroundWorker);
                        InsertLine2TxtOutput("Start: Install Script in Your Server... ");
                        backgroundWorker.RunWorkerAsync(2);
                    }
                    catch
                    {
                        btnRunScript.Enabled = true;
                        btnStop.Enabled = false;
                        btn_SendXML2Naya.Enabled = false;
                        btnSaveXML.Enabled = false;
                        toolStripProgressBar1.Value = 0;
                        timer1.Enabled = false;
                        _Success = false;
                    }

                }
                catch
                {
                    btnRunScript.Enabled = true;
                    btnStop.Enabled = false;
                    btn_SendXML2Naya.Enabled = false;
                    btnSaveXML.Enabled = false;
                    toolStripProgressBar1.Value = 0;
                    timer1.Enabled = false;
                    _Success = false;
                }

            }
            else
            {
                btnRunScript.Enabled = true;
                btnStop.Enabled = false;
                btn_SendXML2Naya.Enabled = false;
                btnSaveXML.Enabled = false;
                toolStripProgressBar1.Value = 0;
                timer1.Enabled = false;
                _Success = false;
            }
        }


        private void BackgroundWorker_DoWork_Step3_BuildScript(object sender, DoWorkEventArgs e)
        {
            try
            {
                var index = e.Argument.ToString();
                e.Result = index;

                //here code that he need doing

                //Script = Script.Replace("USE master;", "");

                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs_TestServer);
                SqlCommand myCommand = default(SqlCommand);
                myCommand = new SqlCommand(Script, myConnection);
                Dictionary_Cmd.TryAdd(Script, myCommand);
                myCommand.Connection.Open();

                SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }

                


                // System.Threading.Thread.Sleep(10000);



            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                 
                MessageOutput = MessageOutput + "\n" + "Exception:" + ex.Message;  
                e.Cancel = true;
            }
        }
        private void BackgroundWorker_RunWorkerCompleted_Step3_BuildScript(object sender, RunWorkerCompletedEventArgs e)
        {
            txtOutput.Text = MessageOutput;

            if (e.Error == null && !e.Cancelled)
            {
                try
                {
                    InsertLine2TxtOutput("End: Install Script in Your Server... ");
                    try
                    {
                        BackgroundWorker backgroundWorker = new BackgroundWorker();
                        backgroundWorker.WorkerSupportsCancellation = true;

                        backgroundWorker.DoWork += new DoWorkEventHandler(BackgroundWorker_DoWork_Step4_RunScript);
                        backgroundWorker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(BackgroundWorker_RunWorkerCompleted_Step4_RunScript);
                        ArrBackgroundWorker.Add(backgroundWorker);
                        InsertLine2TxtOutput("Start: Run Script in Your Server... ");
                        backgroundWorker.RunWorkerAsync(2);
                    }
                    catch
                    {
                        btnRunScript.Enabled = true;
                        btnStop.Enabled = false;
                        btn_SendXML2Naya.Enabled = false;
                        btnSaveXML.Enabled = false;
                        toolStripProgressBar1.Value = 0;
                        timer1.Enabled = false;
                        _Success = false;
                    }

                }
                catch
                {
                    btnRunScript.Enabled = true;
                    btnStop.Enabled = false;
                    btn_SendXML2Naya.Enabled = false;
                    btnSaveXML.Enabled = false;
                    toolStripProgressBar1.Value = 0;
                    timer1.Enabled = false;
                    _Success = false;

                }

            }
            else
            {
                btnRunScript.Enabled = true;
                btnStop.Enabled = false;
                btn_SendXML2Naya.Enabled = false;
                btnSaveXML.Enabled = false;
                toolStripProgressBar1.Value = 0;
                timer1.Enabled = false;
                _Success = false;
            }
        }



        private void BackgroundWorker_DoWork_Step4_RunScript(object sender, DoWorkEventArgs e)
        {
            try
            {
                var index = e.Argument.ToString();
                e.Result = index;

                //here code that he need doing
                //Step 1 

                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs_TestServer);
                SqlCommand myCommand = default(SqlCommand);
                myCommand = new SqlCommand("[dbo].[sp_SiteReview]  @Client,@Allow_Week_Password_Check,@debug,@Display", myConnection);
                SqlParameter uClient = new SqlParameter("@Client", SqlDbType.NVarChar, -1);
                SqlParameter uAllow_Week_Password_Check = new SqlParameter("@Allow_Week_Password_Check", SqlDbType.Bit);
                SqlParameter uDebug = new SqlParameter("@debug", SqlDbType.Bit);
                SqlParameter uDisplay = new SqlParameter("@Display", SqlDbType.Bit);

                uClient.Value = Client;
                uAllow_Week_Password_Check.Value = Allow_Week_Password_Check;
                uDebug.Value = Debug;
                uDisplay.Value = Display;


                myCommand.Parameters.Add(uClient);
                myCommand.Parameters.Add(uAllow_Week_Password_Check);
                myCommand.Parameters.Add(uDebug);
                myCommand.Parameters.Add(uDisplay);
                myCommand.CommandTimeout = 0;
                //( @Client NVARCHAR(255) = N'General Client',@Allow_Week_Password_Check BIT = 0,@debug BIT = 0,@Display BIT = 0)
                Dictionary_Cmd.TryAdd(myCommand.CommandText, myCommand);
                myCommand.Connection.Open();

                
                var adapter = new SqlDataAdapter(myCommand);

                myConnection.InfoMessage += (Sender, args) =>
                {
                    for (var i = 0; i < args.Errors.Count; i++)
                    {
                        if (args.Errors[i].Number > 0)
                        {
                            MessageOutput += "\n" + args.Message + "\n";
                        }
                        else
                        {
                            MessageOutput += args.Message + "\n";
                        }
                    }
                };

                adapter.Fill(XML_dataSet);
               
                strXML =   XML_dataSet.Tables[0].Rows[0].ItemArray[0].ToString() ;
               // SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }
 

            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                MessageOutput = MessageOutput + "\n" + "Exception:" + ex.Message;  
                e.Cancel = true;
            }
        }
        private void BackgroundWorker_RunWorkerCompleted_Step4_RunScript(object sender, RunWorkerCompletedEventArgs e)
        { 
            txtOutput.Text = MessageOutput;
            toolStripProgressBar1.Value = 0;
            timer1.Enabled = false;


            if (e.Error == null && !e.Cancelled)
            {
                try
                {
                    btnRunScript.Enabled = true;
                    btnStop.Enabled = false;
                    btnSaveXML.Enabled = true;
                    btn_SendXML2Naya.Enabled = true;
                    InsertLine2TxtOutput("End: Run Script in Your Server... ");
                    txtXML.Text = PrintXML(strXML.ToString()); 
                    // what happend when finish

                }
                catch
                {
                    btnRunScript.Enabled = true;
                    btnStop.Enabled = false;
                    btn_SendXML2Naya.Enabled = false;
                    btnSaveXML.Enabled = false;
                    _Success = false;
                }

            }
            else
            {
                btnRunScript.Enabled = true;
                btnStop.Enabled = false;
                btn_SendXML2Naya.Enabled = false;
                btnSaveXML.Enabled = false;
                _Success = false;
            }
        }

        public static String PrintXML(String XML)
        {
            String Result = "";

            MemoryStream mStream = new MemoryStream();
            XmlTextWriter writer = new XmlTextWriter(mStream, Encoding.Unicode);
            XmlDocument document = new XmlDocument();

            try
            {
                // Load the XmlDocument with the XML.
                document.LoadXml(XML);

                writer.Formatting = Formatting.Indented;

                // Write the XML into a formatting XmlTextWriter
                document.WriteContentTo(writer);
                writer.Flush();
                mStream.Flush();

                // Have to rewind the MemoryStream in order to read
                // its contents.
                mStream.Position = 0;

                // Read MemoryStream contents into a StreamReader.
                StreamReader sReader = new StreamReader(mStream);

                // Extract the text from the StreamReader.
                String FormattedXML = sReader.ReadToEnd();

                Result = FormattedXML;
            }
            catch (XmlException)
            {
            }

            mStream.Close();
            writer.Close();

            return Result;
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            Stop_Execute(sender);
        }
        private void Stop_Execute(object sender)
        {
            _Cancel = true;
            toolStripProgressBar1.Value = 0;
            timer1.Enabled = false;
            
            foreach (var entry in Dictionary_Cmd)
            {
                entry.Value.Cancel();
            }
            Dictionary_Cmd.Clear();
            ArrBackgroundWorker.Clear();
            InsertLine2TxtOutput("Stopping Execute...");
        }
        private void InsertLine2TxtOutput(String Line)
        {
            MessageOutput = MessageOutput + "\n" + Line;
            txtOutput.Text = MessageOutput;
        }

        private void btnRunScript_Click(object sender, EventArgs e)
        {
            Progress = 0;
            btnRunScript.Enabled = false;
            btnStop.Enabled = true;
            btnTestConnection.Enabled = false;
            Client = txtTitleReport.Text;
            Allow_Week_Password_Check = chk_CheckWeekPasswords.Checked;
            Debug = true;
            Display = true;
            MessageOutput = "";
            strXML= "";
            txtXML.Text = strXML;
            InsertLine2TxtOutput("Starting....");
            timer1.Enabled = true;
            timer1.Interval=50;
            SendToExecute();

        }

        private void ResizeForm()
        {
            int Width = Convert.ToInt32(this.Size.Width);
            int Height = Convert.ToInt32(this.Size.Height);
            txtOutput.Width = Width - 42;
            txtXML.Width = Width - 42;
            lblInstructions.Width = Width - 430 - 24;
            btnSaveXML.Location = new Point(19, (Height - 85));
            btn_SendXML2Naya.Location = new Point(190, (Height - 85));
            txtXML.Height = Convert.ToInt32(Height - txtXML.Location.Y - 100);

        }

        private void MainForm_ResizeEnd(object sender, EventArgs e)
        {
            ResizeForm();


        }
        private void Disable_Buttons()
        {
            btnRunScript.Enabled = false;
            btnStop.Enabled = false;
            btnSaveXML.Enabled = false;
            btn_SendXML2Naya.Enabled = false;
            btnTestConnection.Enabled = true;
        }
        private void txtServerName_KeyPress(object sender, KeyPressEventArgs e)
        {
            Disable_Buttons();
        }

        private void txtLogin_KeyPress(object sender, KeyPressEventArgs e)
        {
            Disable_Buttons();

        }

        private void txtPassword_KeyPress(object sender, KeyPressEventArgs e)
        {
            Disable_Buttons();
        }

        private void toolStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            Progress += 1;
            if (Progress >= 100) 
            {
                Progress = 0;
            }
            toolStripProgressBar1.Value = Progress;
        }

         
        
    }
}
