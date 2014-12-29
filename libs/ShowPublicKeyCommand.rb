require 'tempfile'
require 'RMagick'
require 'rqrcode_png'
require 'libs/Paths.rb'
require 'libs/KeyConfiguration.rb'

class ShowPublicKeyCommand
  def run
    # Load the private key, and get its public key.
    key_config = KeyConfiguration.new(Paths.config_dir)
    public_key = key_config.get_public_key

    # Write the QR code to a temp file.
    qr_file = Tempfile.new(['encc', '.png'])
    qr = RQRCode::QRCode.new( public_key.to_bytes, :size => 5, :level => :h )
    png = qr.to_img
    png.resize(500, 500).save(qr_file)

    # Display that temp file.
    images = Magick::Image.read(qr_file.path)
    images[0].display

    qr_file.close
    qr_file.unlink
  end
end
