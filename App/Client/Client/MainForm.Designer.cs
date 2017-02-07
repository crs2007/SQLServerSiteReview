namespace Client
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        
        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.txtServerName = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.lblLogin = new System.Windows.Forms.Label();
            this.txtLogin = new System.Windows.Forms.TextBox();
            this.lblPassword = new System.Windows.Forms.Label();
            this.txtPassword = new System.Windows.Forms.TextBox();
            this.chkBox_Intergrated = new System.Windows.Forms.CheckBox();
            this.btnRunScript = new System.Windows.Forms.Button();
            this.btn_SendXML2Naya = new System.Windows.Forms.Button();
            this.txtOutput = new System.Windows.Forms.RichTextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.btnSaveXML = new System.Windows.Forms.Button();
            this.btnTestConnection = new System.Windows.Forms.Button();
            this.txtXML = new ScintillaNET.Scintilla();
            this.btnStop = new System.Windows.Forms.Button();
            this.chk_CheckWeekPasswords = new System.Windows.Forms.CheckBox();
            this.txtTitleReport = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.lblInstructions = new System.Windows.Forms.Label();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripProgressBar1 = new System.Windows.Forms.ToolStripProgressBar();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.txtXML)).BeginInit();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // txtServerName
            // 
            this.txtServerName.Location = new System.Drawing.Point(110, 13);
            this.txtServerName.Name = "txtServerName";
            this.txtServerName.Size = new System.Drawing.Size(202, 20);
            this.txtServerName.TabIndex = 0;
            this.txtServerName.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtServerName_KeyPress);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(17, 16);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(87, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Server IP\\Name:";
            // 
            // lblLogin
            // 
            this.lblLogin.AutoSize = true;
            this.lblLogin.Enabled = false;
            this.lblLogin.Location = new System.Drawing.Point(68, 42);
            this.lblLogin.Name = "lblLogin";
            this.lblLogin.Size = new System.Drawing.Size(36, 13);
            this.lblLogin.TabIndex = 3;
            this.lblLogin.Text = "Login:";
            // 
            // txtLogin
            // 
            this.txtLogin.Enabled = false;
            this.txtLogin.Location = new System.Drawing.Point(110, 39);
            this.txtLogin.Name = "txtLogin";
            this.txtLogin.Size = new System.Drawing.Size(202, 20);
            this.txtLogin.TabIndex = 2;
            this.txtLogin.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtLogin_KeyPress);
            // 
            // lblPassword
            // 
            this.lblPassword.AutoSize = true;
            this.lblPassword.Enabled = false;
            this.lblPassword.Location = new System.Drawing.Point(48, 68);
            this.lblPassword.Name = "lblPassword";
            this.lblPassword.Size = new System.Drawing.Size(56, 13);
            this.lblPassword.TabIndex = 5;
            this.lblPassword.Text = "Password:";
            // 
            // txtPassword
            // 
            this.txtPassword.Enabled = false;
            this.txtPassword.Location = new System.Drawing.Point(110, 65);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.PasswordChar = '*';
            this.txtPassword.Size = new System.Drawing.Size(202, 20);
            this.txtPassword.TabIndex = 4;
            this.txtPassword.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtPassword_KeyPress);
            // 
            // chkBox_Intergrated
            // 
            this.chkBox_Intergrated.AutoSize = true;
            this.chkBox_Intergrated.Checked = true;
            this.chkBox_Intergrated.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkBox_Intergrated.Location = new System.Drawing.Point(318, 16);
            this.chkBox_Intergrated.Name = "chkBox_Intergrated";
            this.chkBox_Intergrated.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.chkBox_Intergrated.Size = new System.Drawing.Size(74, 17);
            this.chkBox_Intergrated.TabIndex = 6;
            this.chkBox_Intergrated.Text = "Integrated";
            this.chkBox_Intergrated.UseVisualStyleBackColor = true;
            this.chkBox_Intergrated.CheckedChanged += new System.EventHandler(this.chkBox_Intergrated_CheckedChanged);
            // 
            // btnRunScript
            // 
            this.btnRunScript.Location = new System.Drawing.Point(20, 151);
            this.btnRunScript.Name = "btnRunScript";
            this.btnRunScript.Size = new System.Drawing.Size(144, 24);
            this.btnRunScript.TabIndex = 7;
            this.btnRunScript.Text = "Run Script";
            this.btnRunScript.UseVisualStyleBackColor = true;
            this.btnRunScript.Click += new System.EventHandler(this.btnRunScript_Click);
            // 
            // btn_SendXML2Naya
            // 
            this.btn_SendXML2Naya.Location = new System.Drawing.Point(190, 728);
            this.btn_SendXML2Naya.Name = "btn_SendXML2Naya";
            this.btn_SendXML2Naya.Size = new System.Drawing.Size(157, 23);
            this.btn_SendXML2Naya.TabIndex = 8;
            this.btn_SendXML2Naya.Text = "Send Xml To Naya";
            this.btn_SendXML2Naya.UseVisualStyleBackColor = true;
            this.btn_SendXML2Naya.Click += new System.EventHandler(this.btn_SendXML2Naya_Click);
            // 
            // txtOutput
            // 
            this.txtOutput.BackColor = System.Drawing.SystemColors.Control;
            this.txtOutput.Location = new System.Drawing.Point(16, 211);
            this.txtOutput.Name = "txtOutput";
            this.txtOutput.Size = new System.Drawing.Size(1199, 205);
            this.txtOutput.TabIndex = 9;
            this.txtOutput.Text = "";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(16, 192);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(39, 13);
            this.label4.TabIndex = 10;
            this.label4.Text = "Output";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(16, 444);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(65, 13);
            this.label5.TabIndex = 12;
            this.label5.Text = "Result: XML";
            // 
            // btnSaveXML
            // 
            this.btnSaveXML.Location = new System.Drawing.Point(19, 728);
            this.btnSaveXML.Name = "btnSaveXML";
            this.btnSaveXML.Size = new System.Drawing.Size(157, 23);
            this.btnSaveXML.TabIndex = 13;
            this.btnSaveXML.Text = "Save XML As...";
            this.btnSaveXML.UseVisualStyleBackColor = true;
            this.btnSaveXML.Click += new System.EventHandler(this.btnSaveXML_Click);
            // 
            // btnTestConnection
            // 
            this.btnTestConnection.Location = new System.Drawing.Point(318, 39);
            this.btnTestConnection.Name = "btnTestConnection";
            this.btnTestConnection.Size = new System.Drawing.Size(74, 46);
            this.btnTestConnection.TabIndex = 15;
            this.btnTestConnection.Text = "Test Connection";
            this.btnTestConnection.UseVisualStyleBackColor = true;
            this.btnTestConnection.Click += new System.EventHandler(this.btnTestConnection_Click);
            // 
            // txtXML
            // 
            this.txtXML.BackColor = System.Drawing.SystemColors.Control;
            this.txtXML.Caret.BlinkRate = -1;
            this.txtXML.Location = new System.Drawing.Point(16, 460);
            this.txtXML.Name = "txtXML";
            this.txtXML.Size = new System.Drawing.Size(1199, 262);
            this.txtXML.Styles.BraceBad.FontName = "";
            this.txtXML.Styles.BraceLight.FontName = "";
            this.txtXML.Styles.ControlChar.FontName = "";
            this.txtXML.Styles.Default.BackColor = System.Drawing.SystemColors.Control;
            this.txtXML.Styles.IndentGuide.FontName = "";
            this.txtXML.Styles.LastPredefined.FontName = "";
            this.txtXML.Styles.LineNumber.BackColor = System.Drawing.Color.Transparent;
            this.txtXML.Styles.LineNumber.FontName = "";
            this.txtXML.TabIndex = 16;
            // 
            // btnStop
            // 
            this.btnStop.Enabled = false;
            this.btnStop.Location = new System.Drawing.Point(170, 152);
            this.btnStop.Name = "btnStop";
            this.btnStop.Size = new System.Drawing.Size(142, 23);
            this.btnStop.TabIndex = 17;
            this.btnStop.Text = "Stop Script";
            this.btnStop.UseVisualStyleBackColor = true;
            this.btnStop.Click += new System.EventHandler(this.btnStop_Click);
            // 
            // chk_CheckWeekPasswords
            // 
            this.chk_CheckWeekPasswords.AutoSize = true;
            this.chk_CheckWeekPasswords.Location = new System.Drawing.Point(110, 119);
            this.chk_CheckWeekPasswords.Name = "chk_CheckWeekPasswords";
            this.chk_CheckWeekPasswords.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.chk_CheckWeekPasswords.Size = new System.Drawing.Size(143, 17);
            this.chk_CheckWeekPasswords.TabIndex = 18;
            this.chk_CheckWeekPasswords.Text = "Check Weak Passwords";
            this.chk_CheckWeekPasswords.UseVisualStyleBackColor = true;
            // 
            // txtTitleReport
            // 
            this.txtTitleReport.Location = new System.Drawing.Point(110, 93);
            this.txtTitleReport.Name = "txtTitleReport";
            this.txtTitleReport.Size = new System.Drawing.Size(202, 20);
            this.txtTitleReport.TabIndex = 19;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(24, 96);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(83, 13);
            this.label2.TabIndex = 20;
            this.label2.Text = "Title For Report:";
            // 
            // lblInstructions
            // 
            this.lblInstructions.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblInstructions.Location = new System.Drawing.Point(430, 17);
            this.lblInstructions.Name = "lblInstructions";
            this.lblInstructions.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.lblInstructions.Size = new System.Drawing.Size(779, 158);
            this.lblInstructions.TabIndex = 21;
            this.lblInstructions.Text = resources.GetString("lblInstructions.Text");
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripProgressBar1});
            this.statusStrip1.Location = new System.Drawing.Point(0, 762);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1227, 22);
            this.statusStrip1.TabIndex = 22;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripProgressBar1
            // 
            this.toolStripProgressBar1.Name = "toolStripProgressBar1";
            this.toolStripProgressBar1.Size = new System.Drawing.Size(100, 16);
            // 
            // timer1
            // 
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1227, 784);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.lblInstructions);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.txtTitleReport);
            this.Controls.Add(this.chk_CheckWeekPasswords);
            this.Controls.Add(this.btnStop);
            this.Controls.Add(this.txtXML);
            this.Controls.Add(this.btnTestConnection);
            this.Controls.Add(this.btnSaveXML);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.txtOutput);
            this.Controls.Add(this.btn_SendXML2Naya);
            this.Controls.Add(this.btnRunScript);
            this.Controls.Add(this.chkBox_Intergrated);
            this.Controls.Add(this.lblPassword);
            this.Controls.Add(this.txtPassword);
            this.Controls.Add(this.lblLogin);
            this.Controls.Add(this.txtLogin);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtServerName);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Naya - Client";
            this.ResizeEnd += new System.EventHandler(this.MainForm_ResizeEnd);
            ((System.ComponentModel.ISupportInitialize)(this.txtXML)).EndInit();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox txtServerName;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblLogin;
        private System.Windows.Forms.TextBox txtLogin;
        private System.Windows.Forms.Label lblPassword;
        private System.Windows.Forms.TextBox txtPassword;
        private System.Windows.Forms.CheckBox chkBox_Intergrated;
        private System.Windows.Forms.Button btnRunScript;
        private System.Windows.Forms.Button btn_SendXML2Naya;
        private System.Windows.Forms.RichTextBox txtOutput;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button btnSaveXML;

        private System.Windows.Forms.Button btnTestConnection;
        private ScintillaNET.Scintilla txtXML;
        private System.Windows.Forms.Button btnStop;
        private System.Windows.Forms.CheckBox chk_CheckWeekPasswords;
        private System.Windows.Forms.TextBox txtTitleReport;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lblInstructions;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripProgressBar toolStripProgressBar1;
        private System.Windows.Forms.Timer timer1;
    }
}

