# Swoosh.Attachment

Struct representing an attachment in an email.

## Usage

For all usecases of `new/2` see the function documentation.

## Inline Example

    new()
    |> to({avenger.name, avenger.email})
    |> from({"Red Skull", "red_skull@villains.org"})
    |> subject("End Game invitation QR Code")
    |> html_body(~s|<h1>Hello #{avenger.name}</h1> Here is your QR Code <img src="cid:qrcode.png">|)
    |> text_body("Hello #{avenger.name}. Please find your QR Code attached.\n")
    |> attachment(
      Swoosh.Attachment.new(
        {:data, invitation_qr_code_binary},
        filename: "qrcode.png",
        content_type: "image/png",
        type: :inline)
    )
    |> VillainMailer.deliver()

## new(path, opts \\ [])

Creates a new Attachment

Examples:

    Attachment.new("/path/to/attachment.png")
    Attachment.new("/path/to/attachment.png", filename: "image.png")
    Attachment.new("/path/to/attachment.png", filename: "image.png", content_type: "image/png")
    Attachment.new(params["file"]) # Where params["file"] is a %Plug.Upload
    Attachment.new({:data, File.read!("/path/to/attachment.png")}, filename: "image.png", content_type: "image/png")

Examples with inline-attachments:

    Attachment.new("/path/to/attachment.png", type: :inline)
    Attachment.new("/path/to/attachment.png", filename: "image.png", type: :inline)
    Attachment.new("/path/to/attachment.png", filename: "image.png", content_type: "image/png", type: :inline)
    Attachment.new(params["file"], type: :inline) # Where params["file"] is a %Plug.Upload
    Attachment.new({:data, File.read!("/path/to/attachment.png")}, filename: "image.png", content_type: "image/png", type: :inline)

Inline attachments by default use their filename
(or basename of the path if filename is not specified) as cid,
in relevant adapters.

    Attachment.new("/data/file.png", type: :inline)

Gives you something like this:

    <img src="cid:file.png">

You can optionally override this default by passing in the cid option:

    Attachment.new("/data/file.png", type: :inline, cid: "custom-cid")