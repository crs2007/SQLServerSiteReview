using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace Client
{
    public partial class frmLogin : Form
    {
        String cs = @"Password=Sr@12345^;Persist Security Info=True;User ID=SiteReviewApp;Initial Catalog=SiteReviewUser;Data Source=yellow.database.windows.net; Connect Timeout=60";

        public int ClientID { get { return C; } }
        public int C;
        public frmLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (txtUserName.Text == "")
            {
                MessageBox.Show("Please enter Email", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                txtUserName.Focus();
                return;
            }
            if (txtPassword.Text == "")
            {
                MessageBox.Show("Please enter password", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                txtPassword.Focus();
                return;
            }
            try
            {
                SqlConnection myConnection = default(SqlConnection);
                myConnection = new SqlConnection(cs);

                SqlCommand myCommand = default(SqlCommand);

                myCommand = new SqlCommand("[GUI].[usp_LoginCheck] @eMail,@Password,@ClientID output", myConnection);

                SqlParameter uEmail = new SqlParameter("@eMail", SqlDbType.VarChar);
                SqlParameter uPassword = new SqlParameter("@Password", SqlDbType.VarChar);
                SqlParameter uClientID = new SqlParameter("@ClientID", SqlDbType.Int) { Direction = ParameterDirection.Output };



                uEmail.Value = txtUserName.Text;
                uPassword.Value = txtPassword.Text;
                uClientID.Value = 0;
                uClientID.IsNullable = true;
                myCommand.Parameters.Add(uEmail);
                myCommand.Parameters.Add(uPassword);
                myCommand.Parameters.Add(uClientID);

                myCommand.Connection.Open();

                SqlDataReader myReader = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

                if (!DBNull.Value.Equals(uClientID.Value))
                {
                    if (Convert.ToInt32(uClientID.Value) != 0)
                    {
                        //MessageBox.Show("You have logged in successfully ");
                        C= Convert.ToInt32(uClientID.Value);
                        //Hide the login form
                        this.Hide();
                    }

                    else
                    {
                        MessageBox.Show("Login Failed...Try again !", "Login Denied", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        txtUserName.Clear();
                        txtPassword.Clear();
                        txtUserName.Focus();
                    }
                }
                else
                {
                        MessageBox.Show("Login Failed...Try again !", "Login Denied", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        txtUserName.Clear();
                        txtPassword.Clear();
                        txtUserName.Focus();

                }
                if (myConnection.State == ConnectionState.Open)
                {
                    myConnection.Dispose();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                txtUserName.Clear();
                txtPassword.Clear();
                txtUserName.Focus();
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void txtPassword_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13) //Enter

            {
                btnLogin_Click(sender, e);
            }
        }
        
    }
}
